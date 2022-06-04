# ride_sharing_app
The purpose of Ride_Sharing_App is to help users share their cars with passengers.
<img width="480" alt="Screen Shot 2022-06-04 at 18 02 39" src="https://user-images.githubusercontent.com/52280308/172015178-89c86dab-fbee-4597-8670-c4d995c64fa3.png">

## Description
Map methods were coded with Flutter and Google Maps API.
Places API is used for autocomplete in address search.
Firebase is used for storage, realtime database.

## Prerequisites
- keys.xml file on Android > App > src > main > res > values
``` 
  <?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_maps_key" translatable="false"    templateMergeStrategy="preserve">
        YOUR_GOOGLE_MAP_API_KEY_HERE
    </string>
</resources>
 ```

- .env file on main directory
```
GOOGLE_API_KEY=YOUR_API_KEY_HERE
```

- google-services.json and GoogleService-Info.plist configuration files from Firebase


## Screenshots
-All Listings
<img width="436" alt="Screen Shot 2022-06-04 at 18 02 09" src="https://user-images.githubusercontent.com/52280308/172015341-fcc69074-42eb-4d89-80c5-52a625b14235.png">

-Autocomplete Search-
<img width="480" alt="Screen Shot 2022-06-04 at 18 34 51" src="https://user-images.githubusercontent.com/52280308/172015363-da3acc07-529e-424c-975d-9f8de78f2b2c.png">

-Search Listing with End Location
<img width="480" alt="Screen Shot 2022-06-04 at 18 35 03" src="https://user-images.githubusercontent.com/52280308/172015389-a58eb76f-ad2f-4dfb-b768-62969fb0fa0c.png">

-Search Listings by device location
<img width="480" alt="Screen Shot 2022-06-04 at 18 36 15" src="https://user-images.githubusercontent.com/52280308/172015420-e9a4bda6-2822-443b-97d2-92e9605e902e.png">

-Chat Screen
<img width="404" alt="chat" src="https://user-images.githubusercontent.com/52280308/172015444-5c0dd348-06ff-41f8-811f-4de172505f0e.png">

-Profile Page Screen
<img width="480" alt="Screen Shot 2022-06-04 at 18 36 24" src="https://user-images.githubusercontent.com/52280308/172015454-0dd97898-2492-4c36-89d8-2d7f83111be9.png">