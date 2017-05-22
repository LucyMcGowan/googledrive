passing queries in the dots!
================
Lucy D’Agostino McGowan
5/9/2017

-   [List files](#list-files)
-   [Publish files](#publish-files)
-   [Share files](#share-files)
-   [Uploading a file](#uploading-a-file)
-   [clean up](#clean-up)

*This is all about those dots[.](https://www.youtube.com/watch?v=GI6CfKcMhjY)*

Most of the functions have `...` which allow the user to input name-value pairs to query the API.

``` r
library('googledrive')
library('dplyr')
```

List files
----------

We list files using `drive_ls()`[.](https://www.youtube.com/watch?v=F-X4SLhorvw) Possible parameters to pass to the `...` can be found here. For example, by default files are listed in descending order by most recently modified.

Here is my list using the default:

``` r
drive_ls()
```

    ## # A tibble: 100 × 3
    ##                                                name        type
    ##                                               <chr>       <chr>
    ## 1                           \U0001f33b Lucy & Jenny    document
    ## 2               Football Stadium Survey (Responses) spreadsheet
    ## 3                           Football Stadium Survey        form
    ## 4                                 Happy Little Demo    document
    ## 5                                    THIS IS A TEST      folder
    ## 6  Vanderbilt Graduate Student Handbook (Responses) spreadsheet
    ## 7                  WSDS Concurrent Session Abstract    document
    ## 8                 R-Ladies Nashville 6-Month Survey        form
    ## 9            Health Insurance Questions (Responses) spreadsheet
    ## 10                       Health Insurance Questions        form
    ## # ... with 90 more rows, and 1 more variables: id <chr>

Let's say I want to order them by folders, then modified time, then name. I can do that!

``` r
drive_ls(orderBy = "folder,modifiedTime desc,name" )
```

    ## # A tibble: 100 × 3
    ##                       name   type                           id
    ##                      <chr>  <chr>                        <chr>
    ## 1           THIS IS A TEST folder 0Bw9rJumZU4vER2lldjVBZ1I0SDA
    ## 2                 r-ladies folder 0Bw9rJumZU4vEVm5fbGtYVDVRYnc
    ## 3  public-health-hackathon folder 0Bw9rJumZU4vEd3NwclZQR0k4QWs
    ## 4                enar-2017 folder 0Bw9rJumZU4vETWJ1YWczc2NJVjA
    ## 5                     lucy folder 0Bw9rJumZU4vEWm9SY3FnemEwVTg
    ## 6                    rpubs folder 0Bw9rJumZU4vEVHh2OC1ta0tFbGc
    ## 7                rpubs.com folder 0Bw9rJumZU4vEeC1xb1RYQ2JoTWc
    ## 8             shinyapps.io folder 0Bw9rJumZU4vEY2VtbXdfZ2NHOGs
    ## 9                 plot.Rmd folder 0Bw9rJumZU4vEODhlb2llYU1Jb1U
    ## 10              slides.Rmd folder 0Bw9rJumZU4vEX3otVkxzUEluUWc
    ## # ... with 90 more rows

As another example, by default, this will list 100 drive files. If we want to output more, we can pass the `pageSize` parameter[.](https://www.youtube.com/watch?v=cRpdIrq7Rbo&t=67s)

``` r
drive_ls(pageSize = 200)
```

    ## # A tibble: 200 × 3
    ##                                                name        type
    ##                                               <chr>       <chr>
    ## 1                           \U0001f33b Lucy & Jenny    document
    ## 2               Football Stadium Survey (Responses) spreadsheet
    ## 3                           Football Stadium Survey        form
    ## 4                                 Happy Little Demo    document
    ## 5                                    THIS IS A TEST      folder
    ## 6  Vanderbilt Graduate Student Handbook (Responses) spreadsheet
    ## 7                  WSDS Concurrent Session Abstract    document
    ## 8                 R-Ladies Nashville 6-Month Survey        form
    ## 9            Health Insurance Questions (Responses) spreadsheet
    ## 10                       Health Insurance Questions        form
    ## # ... with 190 more rows, and 1 more variables: id <chr>

Publish files
-------------

To publish files, we use `drive_publish()`. Parameters found [here](https://developers.google.com/drive/v3/reference/revisions/update) can be passed to the `...` of this function. For example, by default for Google Docs, subsequent revisions will be automatically republished. We can change this by passing the `publishAuto` parameter.

``` r
my_file <- drive_get_id("test") %>%
  drive_file %>%
  drive_publish(publishAuto=FALSE)
```

    ## You have changed the publication status of 'remark-latest.min.js'.

``` r
my_file$publish
```

    ## # A tibble: 1 × 5
    ##            check_time                                            revision
    ##                <dttm>                                               <chr>
    ## 1 2017-05-11 10:47:44 0Bw9rJumZU4vENmZLUno5djQxMldFcmwvU1h6UVZNVTNMOHBvPQ
    ## # ... with 3 more variables: published <lgl>, auto_publish <lgl>,
    ## #   last_user <chr>

Share files
-----------

To share files, we use `drive_share()`. Parameters that can be passed to the `...` can be found [here](https://developers.google.com/drive/v3/reference/permissions/create). For example, if we set the `type` parameter as `anyone`, we can pass the `allowFileDiscovery` through the `...` to allow anyone to discover the file (this is equivalent to being "Public on the Web").

``` r
my_file <- my_file %>%
  drive_share(type = "anyone", role = "writer", allowFileDiscovery = TRUE)
```

    ## The permissions for file 'remark-latest.min.js' have been updated

``` r
my_file$permissions
```

    ## # A tibble: 3 × 9
    ##               kind                   id   type            emailAddress
    ##              <chr>                <chr>  <chr>                   <chr>
    ## 1 drive#permission 13813982488463916564   user lucydagostino@gmail.com
    ## 2 drive#permission               anyone anyone                    <NA>
    ## 3 drive#permission       anyoneWithLink anyone                    <NA>
    ## # ... with 5 more variables: role <chr>, displayName <chr>,
    ## #   photoLink <chr>, deleted <lgl>, allowFileDiscovery <lgl>

I also display this in the print method.

``` r
my_file
```

    ## File name: remark-latest.min.js 
    ## File owner: Lucy D'Agostino 
    ## File type: application/javascript 
    ## Last modified: 2017-05-11 
    ## Access: Anyone on the internet can find and access. No sign-in required.

Uploading a file
----------------

To upload a file we use `drive_upload()`. Parameters that can be passed to the `...` can be found [here](https://developers.google.com/drive/v3/reference/files/update). For example, if you would like to add a file to a specific folder, and do not want to use the `drive_mv` function after, you can use `addParents`.

Let's grab a folder to stick the file in.

``` r
folder <- drive_get_id("THIS IS A TEST") %>%
  drive_file
```

Make sure it's a folder.

``` r
folder
```

    ## File name: THIS IS A TEST 
    ## File owner: Lucy D'Agostino 
    ## File type: folder 
    ## Last modified: 2017-05-08 
    ## Access: Shared with specific people.

Upload to the folder.

``` r
new_file <- drive_upload("demo.txt",addParents = folder$id)
```

    ## File uploaded to Google Drive: 
    ## demo.txt 
    ## As the Google document named:
    ## demo

clean up
--------

``` r
new_file <- drive_delete(new_file)
```

    ## The file 'demo' has been deleted from your Google Drive
