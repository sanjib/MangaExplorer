# MangaExplorer

##Introduction

![MangaExplorer App Icon](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/MangaExplorer/Images.xcassets/AppIcon.appiconset/manga-explorer-180.png)

_Image Credits: Shoho Sato, author of "Say Hello to Black Jack"_

Manga Explorer is an iOS app for discovering new mangas of your choice. You can find 
detailed information like plot description, authors, alternative titles and characters. 
Mangas are ranked using data from Anime News Network. The ranking is based on a bayesian 
average of median, arithmetic and weighted mean of ratings provided by users. 
Character information is fetched from Ani List.

Manga Explorer does not sell mangas but you can add mangas to your Wish List or Favorites 
List for easy access when visiting a book shop or online store to look up which mangas 
you could consider buying based on the ranking and plot summary.

You can use Manga Explorer to discover new mangas using the Genre tab or search for your 
favorite mangas by title or author directly from the Search tab. You can also share 
beautiful snapshots of manga details with your friends.

##User Notes

1. Upon first install, the app will load the database with pre-fetched records of manga 
   (from Anime News Network) for a better user experience.    

2. Upon first run of the app, it will fetch the latest mangas from Anime News Network.
   The user can later specify in Settings if latest available mangas should be fetched 
   daily, weekly or monthly.

3. There are 5 tabs available:
    
   - Top Rated: Displays the top rated mangas ranked by Anime News Network user votes.
     The number of top rated mangas that should be displayed can be controlled in the
     Settings tab. 
     
    ![Top Rated tab](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/top-rated.png)
     
     Manga Details:
     Clicking on a Manga displays the details: Manga title, creators, plot summary, 
     alternative titles, and manga characters. The characters are fetched live from
     AniList. Users can also add or remove a manga from their Wish List or Favorites.
     Users can also share mangas with their friends by clicking on the Action button
     in the navigation bar. Data source is also listed, clicking on the Anime News 
     Network button will open the browser with the relevant manga information, whereas
     clicking on the Ani List button will show the manga browsing page at Ani List.

    ![Manga Details tab](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/manga-details.png)
     
   - Genres: Displays manga genres alphabetically. The number of mangas under each genre
     is also displayed. Clicking on a manga displays its details.
     
    ![Genres tab](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/genres.png)
     
   - Search: Provides users search functionality by title or author. Clicking on a search
     result display manga details.

    ![Search tab](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/search.png)
     
   - My Lists: Provides Wish List and Favorites List. Mangas are added or removed from 
     these two lists in the Manga Details view. Clicking on a manga in the My Lists tab
     will show manga details.

    ![Favorites List](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/favorites.png)
     
   - Settings: Shows the About Us, Tell a Friend, Fetch Frequency, Number of Mangas to
     Display and total mangas available in the database. This number will increase from
     time to time as latest mangas are fetched on a daily, weekly or monthly basis.

    ![Settings tab](https://raw.githubusercontent.com/sanjibahmad/MangaExplorer/master/Screenshots/settings.png)

##Developer Notes

1. Anime News Network is the most reliable source of manga information that we have been
   able to find. Their ratings system is very good and they have a large collection of
   mangas in their database (over 7,900). But their API is very limited, for example it
   doesn't allow search or browse by genres. To overcome this limitation we pre-fetched
   information from Anime News Network and pre-load the app with this information upon
   first install. Later the app updates itself with the latest available mangas that get
   added to Anime News Network on daily, weekly or monthly basis as set by the user.
   The initialization screen uses NSProgress. Anime News Network API fetches XML data.
   
2. The other source of manga information is Ani List where manga character information 
   is fetched. The combination of information from Anime News Network and Ani List
   provides richer manga content. Ani List API fetches JSON data.

3. The app uses custom Collection and Table View Cells, UIButtons and a custom 
   UISegmented Control.
   
4. All manga information is stored in Core Data, user settings are stored through
   NSUserDefaults and manga images are stored in the user documents directory.
   
5. The Manga Details view combines static table view cells with a collection view that 
   displays manga characters.
   
6. The search feature uses the more modern UISearchController class.

7. The model contains the following entities: manga, genre, staff, alternative title,
   and character.
   
8. The app uses an open source class IJReachabilityType to detect network availability.
