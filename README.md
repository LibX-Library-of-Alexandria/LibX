# LibX

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An app that allows users to browse through different databases, create curated lists, and share their lists with friends and other users.

### App Evaluation

- **Category:** Lifestyle
- **Mobile:** Real-time
- **Story:** Share preferences, discover new content, and stay connected with friends and family; amalgamation of all interests
- **Market:** Young adults and older
- **Habit:** Daily
- **Scope:** Stripped down version would still be interesting to build

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can log into their account
- [x] User can create curated lists of items
- [x] User can browse through a catalogue of movies, books, TV Shows, and Restaurants
- [x] User can search for movie, book, TV show, or restaurant within specific database
- [x] User can see item details
- [x] User can add to / remove items from lists
- [x] User can share lists with people


**Optional Nice-to-have Stories**

- [ ] User can search through database of restaurants
- [ ] User can follow/friend other users and see other lists
- [ ] User can associate a list with a single item
- [ ] User is able to sort items in list by date, alphabetical order, etc.
- [x] User can “check off” items in list
- [ ] Additional catalogues
- [ ] User can see skeleton of app when loading
- [ ] User can like lists
- [ ] User receives updates on other users' lists<br>
... more in [project page](https://github.com/LibX-Library-of-Alexandria/LibX/projects/1)


### 2. Screen Archetypes

* Login/Registration
   * User can log into their account
   * User can create a new account
* Stream
   * User can search through a catalogue of movies, books, TV Shows, Songs, and Restaurants
   * User can create curated lists of items
   * User can add to / remove items from lists
    * User can share lists with people
    * User is able to sort items in list by date, alphabetical order, etc.
    * User can “check off” items in list
* Detail
    * User can see item details
* Creation
    * User can create curated lists of items

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Search
* Lists
* Users *

\* = Additional feature

**Flow Navigation** (Screen to Screen)

* Search
   * Databases (Movies, TV, Books, Music, Food)
   * Details screens
* Lists
   * Curated lists
   * Details screens
* Users
    * User database
    * Details screens

## Wireframes
<img src="http://g.recordit.co/XHKmqrzLao.gif" width=600>

## Schema 

### Models

#### User

| Property | Type     | Description |
| -------- | -------- | ------------|
| objectId | String	  | unique id for the user object *
| username | String   | name of current user *
| password | String   | password of current user *
| email    | String   | email of current user *
|createdAt | DateTime | date when post is created *
| updatedAt| DateTime |	date when post is last updated *

#### List

| Property | Type     | Description |
| -------- | -------- | ------------|
| objectId | String   | unique id for the user object *
| user     | Pointer to User | points to user who created list
| title    | String   | title of user's created list
| photo    | File     | image displayed for created list
|createdAt | DateTime | date when post is created *
| updatedAt| DateTime |	date when post is last updated *

#### Item

| Property | Type     | Description |
| -------- | -------- | ------------|
| objectId | String   | unique id for the user object *
| itemId   | String   | item's id from api
| details  | JSON Object | item's specific details information
| list     | Pointer to List | points to list item belongs to
| checked  | Boolean | evaluates if item has been checked by user in list
|createdAt | DateTime | date when post is created *
| updatedAt| DateTime |	date when post is last updated *

\* = Default field

### Networking
* User Lists Screen
    * (Read/GET) Query all lists created by user
    * (Create/POST) Create a new list
    * (Delete/DELETE) Delete existing list
* List Screen
    * (Read/Get) All items associated with list
    * (Delete/DELETE) Delete item in list
* Details Screen
    * (Create/POST) Add item to a list
* Share Screen
    * (Read/GET) List all items in list in text format

#### API Endpoints
* Google Books
    Base URL = `https://www.googleapis.com/books/v1/volumes?q=`

| HTTP Verb | Endpoint | Description |
| --------- | -------- | ----------- |
| GET       | <user input>  | Gets books with user input's text in title
| GET       | subject:\<subject\>  | Gets books related to specific subject

* The Movie Database API
    * Movies
    Base URL = `https://api.themoviedb.org/3/movie/upcoming?api_key=<insert api_key>&language=en-US&page=1`
    * TV Shows
    Base URL = `https://api.themoviedb.org/3/tv/latest?api_key=<<api_key>>&language=en-US`

| HTTP Verb | Endpoint | Description |
| --------- | -------- | ----------- |
| GET       | Base URL  | Gets latest movies
| GET       | Base URL | Gets latest TV shows

* Yelp API
    Base URL = `https://api.yelp.com/v3/transactions/delivery/search?`
    
| HTTP Verb | Endpoint | Description |
| --------- | -------- | ----------- |
| GET       | latitue=<coordinates>  | Gets restaurants close to coordinates
| GET       | longitude=<coordinates> | Gets restaurants close to coordinates

##### Additional API Endpoints
* Song API
    Base URL = `http://ws.audioscrobbler.com/2.0/`

| HTTP Verb | Endpoint | Description |
| --------- | -------- | ----------- |
| GET       | track.getInfo  | Gets song info that corressponds to the passed artist and song name 
| GET       | chart.getTopArtists | Gets top chart artists

## Sprints

### Sprint 1
- [x] User can log into their account
- [x] User can create curated lists of items
- [x] User can search through a catalogue of movies, books, TV Shows, and Restaurants

<img src="http://g.recordit.co/ZgONaEojBW.gif">

#### Additional Notes
* Switched from Last.fm API to Yelp API for last database feature (will be implemented in next sprint)
* Auto-layouts for cells to be finalized in next sprint

### Sprint 2
- [x] User can search for movie, book, TV show, or restaurant within specific database
- [x] User can see item details

<img src="http://g.recordit.co/2yPeHGcsbQ.gif">

#### Additional Notes
* Our updated design for the app reverted to a previous version, will address in last Sprint
* Code for the Movie and Screen Details Screen needs to be debugged (error with optionals)*FIXED

### Sprint 3
- [x] User can add to / remove items from lists
- [x] User can share lists with people

<img src="http://g.recordit.co/gIjzRXpWMK.gif"><img src="http://g.recordit.co/yhC3iG7Dek.gif"><img src="http://g.recordit.co/Yh5cL1vST1.gif">

#### Additional Notes
* Can share lists via email
