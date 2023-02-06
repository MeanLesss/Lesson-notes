* Need to use dotnet 6
# Umbraco Installation command:

```
dotnet new -i Umbraco.Templates::10.0.0
dotnet new umbraco -n "MyProject"
dotnet run --project "MyProject"
```
--or--
# package script writer:
```
psw.codeshare.co.uk
go to option > (set up script) > update script > 
copy and paste in terminal .
```

# After install and run:

## Open Umbraco  in website to login  
```
localhost:port/umbraco
```
## To make folder :
```
go to Settings > Document Types > (input name)
```

## To add file to folder or make a template:
```
go to Setting > Document Types > (any desired folder) >
hover on the folder and select the three dot >
create Document type with Template > (Input page name)
```

## To edit the created template:
```
Select the template to edit > Templates (in the corner) >
(input the name ) > Save
```

## To get the page to display in as the content we need to enable
the setting in the page as `root`:
```
go to settings > document type pages > 
(The page that need to display) > Permissions > Enable (Allow as root)
```

## After allow as root:
```
go to Content > Page that added > Create template > Input name > 
Input page title 
``` 

# Creating models : 
 To create a model we can go to 
```
Settings > Models building > Generate Models > Reload the console >
```
# `So content is like a class that contain property to display.`
# `Note:` everytime we made a new content we need to buile the model again.
# `Composition` is an element we can reuse that have property or a property class template like a class model.
# `Content` is retreiving property from the composition and value to display can be added in the content page.



# `Multi page view`
## `Note` 1 view need 1 composition and when created view we will a composition

## In Templates folder :
### `Need to make sure` the new templates page have the inheritance to master template.

## `In master file`:
### We contain the html dochtml ,script and css
### also `need to` import the view into the master layout
```
@await.Html.PartialAsync("~/.../.../.../*.cshtml")
--also add--
@RenderBody()
```

# `Permission` to add another page after the root page:

### 1. click on the root content page in contents (this will go to permission page in setting/pages/(the root page file).
### 2. in allow child node types (click on add child > and find the file that needed
### 3. in content select on the page that need to have a subfile `you can create an item under the root page`

# `Note:` Once child node added to root the path of all directory such as CSS or any other Assets we have to check all right path. (We just need to add / indicate the start path from root folder.
 

##`Partials Folder/Page:`
### `Patial` view is the display content that can be used in any part of the website

# Main Navigation:

