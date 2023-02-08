# Day 1 `(7/Feb/2023)`
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
# `Note:`
### everytime we made a new content we need to buile the model again.
## `Composition` is an element we can reuse that have property or a property class template like a class model.
## `Content` is retreiving property from the composition and value to display can be added in the content page.

# `Multi page view`
# `Note`
### 1 view need 1 composition and when created view we will a composition.


## `In Templates folder` :
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

# `Note:` 
### Once child node added to root the path of all directory such as CSS or any other Assets we have to check all right path. (We just need to add / indicate the start path from root folder.
 

## `Partials Folder/Page:`
### `Patial` view is the display content that can be used in any part of the website

# `Navigation`: [click here to check the video guide](https://www.youtube.com/watch?v=1kPyds7Z8Go&list=PL90L_HquhD-81xTOCLLJZLl1roU6hXPhp&index=6)

## Dynamic navigation:
We create a new composition for navigation:
```
Input composition name > add a tab > input name > Add property > select editor > multi url picker > save
```
Go to
``` 
main root page > composition > select the created navigation composition :
```

We use `Umbraco.AssignedContentItem.AncestorOrSelf<HomePage>();` Class to render out the main page :
```
@{
    var homePage = Umbraco.AssignedContentItem.AncestorOrSelf<HomePage>();
}
```
after that in `href`:
```
<a href="@homePage.Url()">@homePage.Name</a>
```
-   `@homePage.Name`: display name of the page

-   `@homePage.Url()`: get the mian page url `path/name`

# `CRUD Operation:` [This is the link to basic CRUD operation with Umbraco form](https://www.youtube.com/watch?v=l0X9DOwd6zk)

# Day 2 `(8/Feb/2023)`
## Started the cred to log in in Umbraco localhost:
```
Name: sokvimean
Email: sokvimean@gmail.com
pass : sokvimean123
```

# To `Reset ADMIN` local login cred:
## First
```
appsetting.json > remove the connection string
```
## Second
```
start the server again > set up a new cred
```
## After reinstall database config
### we will need to check the info inside user content
```
go to user > check user admin > look at email > change the password
``` 


## `Note: ` we can use @Mode.Value("valueName..") to access the value from partial view
--or--

## We can use insert on the interface to generate the Model getValue.

<br>

# To get the Image from the content:
```
@{
    <!-- Assign a variable equal to model value -->
    var image = Model.Value<IPublishedContent>("mainImage");
}
```

## To get the image url `example`:
```
<header class="masthead" style="background-image: url('@image.Url()')">
        ...
</header>
```

## `Visibility navigation `(hide/Visible):
```
create a composition > input a name > add a Tab > add a Property > Enter a name for the property > MUST change the alias name to `umbracoNaviHide` > Add Editor (true/false) > Save
```

### inside navigation.cshtml (Partial view that hold navigation list):
add a function clause and use the Umbraco function
```
@{
    var homePage = Umbraco.AssignedContentItem.AncestorOrSelf<HomePage>();
    var children = homePage?.Children?.Where(x => x.IsVisible()) ?? Enumerable.Empty<IPublishedContent>();
}
```
dynamically get the nav content
```
<ul class="navbar-nav ms-auto py-4 py-lg-0">
    @if (children != null && children.Any())
    {
        <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@homePage?.Url()">Home</a></li>
        foreach (var child in children)
        {
            <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@child.Url()">@child.Name</a></li>
        }
    }
 </ul
```

# `Site navigation by compostion` (Method 2):
```
create a composition file > Enter the name >
Add property > Enter property name > Add Editor (Multi URL Picker) > save 
```
## After navigation compostion is created: 
```
Add the composition to the Home page or main page > edit in the content 
> Navigation compostion > Add > Set link to page (one by one and by order of the page)
```

## After config content already:
We will change the `children` method to other method getting all the path from the nav composition.
```
@{
    var homePage = Umbraco.AssignedContentItem.AncestorOrSelf<HomePage>();
    var children = homePage?.MainNavigation;
}
```
Then :

```
<ul class="navbar-nav ms-auto py-4 py-lg-0">
    @if (children != null && children.Any())
    {
        <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@homePage?.Url()">Home</a></li>
        foreach (var child in children)
        {
            <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@child.Url">@child.Name</a></li>
            }
        }
</ul>
```
## Navigation `Method 3`
```
@{
    var homePage = Model.AncestorOrSelf();
    var children = homePage?.Children;
}
``` 
When loop render output:
```
<ul class="navbar-nav ms-auto py-4 py-lg-0">
    @if (children != null && children.Any())
    {
        <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@homePage?.Url()">Home</a></li>
        foreach (var child in children)
        {
            if (child != null)
            {
                <li class="nav-item"><a class="nav-link px-lg-3 py-3 py-lg-4" href="@child.Url()">@child.Name</a></li>
            }
        }
    }
</ul>
```


# Day 3 `(9/Feb/2023)`

## Try to fix the duplicate packages in umbraco 10

### Use `_ViewImports.cshtml` if not exits you can create the file in `Partial View`(Folder) and paste in the follwing code:
```
@using Umbraco.Extensions
@using CMSTest
@using Umbraco.Cms.Web.Common.PublishedModels
@using Umbraco.Cms.Web.Common.Views
@using Umbraco.Cms.Core.Models.PublishedContent
@using Microsoft.AspNetCore.Html
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
@addTagHelper *, Smidge
@inject Smidge.SmidgeHelper SmidgeHelper 
```

## inherits uses
### In lower version
Allways use
```

@inherits Umbraco.Web.Mvc.UmbracoViewPage 
```
And if you use ModelsBuilder use:
```
@inherits Umbraco.Web.Mvc.UmbracoViewPage<someclass> 
```

You don't need UmbracoTemplatePage with latest Umbraco, it contains the same methods but with Dynamics support.

UmbracoTemplatePage is mostly a convenience, it is the same as UmbracoViewPage

[Really great explanations here](https://our.umbraco.org/forum/developers/api-questions/52597-What-is-the-difference-between-UmbracoViewPage-and-UmbracoTemplatePage)


### For `Umbraco 10` Use:
```
@using Umbraco.Cms.Web.Common.PublishedModels;
@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage
```