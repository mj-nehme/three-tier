package main

// Code originally imported from two sources, merged together and added some relevant stuff:
// -> https://blog.logrocket.com/integrating-mongodb-go-applications/
// -> https://gist.github.com/mschoebel/9398202

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/gorilla/securecookie"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

var localhost = "127.0.0.1"

var http_port = 8000
var mongodb_port = 27017
var database_name = "login_app"
var collection_name = "users"
var username = "Ahmad"
var password = "Pass123"
var usersCollection *mongo.Collection

// cookie handling
var cookieHandler = securecookie.New(
	securecookie.GenerateRandomKey(64),
	securecookie.GenerateRandomKey(32))

func getUserName(request *http.Request) (userName string) {
	if cookie, err := request.Cookie("session"); err == nil {
		cookieValue := make(map[string]string)
		if err = cookieHandler.Decode("session", cookie.Value, &cookieValue); err == nil {
			userName = cookieValue["name"]
		}
	}
	return userName
}

func setSession(userName string, response http.ResponseWriter) {
	value := map[string]string{
		"name": userName,
	}
	if encoded, err := cookieHandler.Encode("session", value); err == nil {
		cookie := &http.Cookie{
			Name:  "session",
			Value: encoded,
			Path:  "/",
		}
		http.SetCookie(response, cookie)
	}
}

func clearSession(response http.ResponseWriter) {
	cookie := &http.Cookie{
		Name:   "session",
		Value:  "",
		Path:   "/",
		MaxAge: -1,
	}
	http.SetCookie(response, cookie)
}

// login handler

func loginHandler(response http.ResponseWriter, request *http.Request) {
	name := request.FormValue("name")
	pass := request.FormValue("password")
	redirectTarget := "/"
	ok := verifyCredentials(name, pass)
	if ok {

		setSession(name, response)
		redirectTarget = "/internal"
	} else {
		// print invalid login
		fmt.Fprintf(response, "<h1>Invalid login</h1><a href=\"/\">Try again</a>")
	}
	http.Redirect(response, request, redirectTarget, http.StatusFound)
}

// logout handler

func logoutHandler(response http.ResponseWriter, request *http.Request) {
	clearSession(response)
	http.Redirect(response, request, "/", http.StatusFound)
}

// index page

const indexPage = `
<h1>Login</h1>
<form method="post" action="/login">
    <label for="name">User name</label>
    <input type="text" id="name" name="name">
    <label for="password">Password</label>
    <input type="password" id="password" name="password">
    <button type="submit">Login</button>
</form>
`

func indexPageHandler(response http.ResponseWriter, request *http.Request) {
	fmt.Fprint(response, indexPage)
}

// internal page

const internalPage = `
<h1>Internal</h1>
<hr>
<small>You're welcome %s</small>
<form method="post" action="/logout">
    <button type="submit">Logout</button>
</form>
`

func internalPageHandler(response http.ResponseWriter, request *http.Request) {
	userName := getUserName(request)
	if userName != "" {
		fmt.Fprintf(response, internalPage, userName)
	} else {
		http.Redirect(response, request, "/", http.StatusFound)
	}
}

// server main method

var router = mux.NewRouter()

// getMongoDBIP parses command line arguments and returns the MongoDB IP
func getMongoDBIP() string {
	var mongodb_ip string
	if len(os.Args) > 1 {
		if os.Args[1] == "" {
			mongodb_ip = localhost
		} else {
			mongodb_ip = os.Args[1]
		}
	} else {
		mongodb_ip = localhost
	}
	return mongodb_ip
}

// initializeApp sets up the database connection and creates users
func initializeApp(mongodb_ip string) {
	fmt.Println("Mongodb IP: ", mongodb_ip)
	usersCollection = connectDB(mongodb_ip)
	if usersCollection != nil {
		createUsers()
	} else {
		fmt.Println("Warning: Running without database connection. Login will use hardcoded credentials.")
	}
}

// setupRouter configures all the HTTP routes
func setupRouter() *mux.Router {
	router.HandleFunc("/", indexPageHandler)
	router.HandleFunc("/internal", internalPageHandler)
	router.HandleFunc("/login", loginHandler).Methods("POST")
	router.HandleFunc("/logout", logoutHandler).Methods("POST")
	return router
}

// startServer starts the HTTP server on the specified port
func startServer(port int) error {
	http.Handle("/", router)
	fmt.Printf("Server starting on port %d...\n", port)
	return http.ListenAndServe(":"+strconv.Itoa(port), nil)
}

// runApp is the main application logic, separated for testing
func runApp() {
	mongodb_ip := getMongoDBIP()
	initializeApp(mongodb_ip)
	setupRouter()
}

func main() {
	runApp()

	err := startServer(http_port)
	if err != nil {
		fmt.Printf("Failed to start server: %v\n", err)
	}
}

func connectDB(mongodb_ip string) *mongo.Collection {
	fmt.Println(mongodb_ip)
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI("mongodb://"+mongodb_ip+":"+strconv.Itoa(mongodb_port)+"/"))
	if err != nil {
		fmt.Printf("Failed to connect to MongoDB: %v\n", err)
		return nil
	}
	if err := client.Ping(context.TODO(), readpref.Primary()); err != nil {
		fmt.Printf("Failed to ping MongoDB: %v\n", err)
		return nil
	}

	db := client.Database(database_name)
	db.CreateCollection(context.TODO(), collection_name)
	fmt.Println("Successfully connected to MongoDB")
	return db.Collection(collection_name)
}

func createUsers() {
	if usersCollection == nil {
		fmt.Println("Skipping user creation - no database connection")
		return
	}
	// insert a single document into a collection
	// create a bson.D object
	user := bson.D{{Key: "username", Value: username}, {Key: "password", Value: password}}
	// insert the bson object using InsertOne()
	_, err := usersCollection.InsertOne(context.TODO(), user)
	// check for errors in the insertion
	if err != nil {
		fmt.Printf("Failed to create user: %v\n", err)
	} else {
		fmt.Println("Default user created successfully")
	}
}

func verifyCredentials(user string, pass string) bool {
	// If no database connection, use hardcoded credentials for demonstration
	if usersCollection == nil {
		fmt.Println("Using hardcoded credentials (no database)")
		return user == username && pass == password
	}

	// retrieve single and multiple documents with a specified filter using FindOne() and Find()
	// create a search filer
	//filter := bson.D{{Key: "username:", Value: user}, {Key: "password", Value: pass}}
	filter := bson.D{
		{Key: "username", Value: user},
		{Key: "password", Value: pass},
	}

	var result bson.D
	err := usersCollection.FindOne(context.TODO(), filter).Decode(&result)
	return err == nil
}
