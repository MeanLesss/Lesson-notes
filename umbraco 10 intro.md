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
```
Open Umbraco after in website 
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

