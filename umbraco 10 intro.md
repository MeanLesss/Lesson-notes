# Day 1 `(6/Feb/2023)`
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

# Day 2 `(7/Feb/2023)`
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
    var homePage = Model.AncestorOrSelf(1); //1 is the level it needed
    var children = homePage?.Children;
}
``` 
## When loop render output:
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
## Model.Content is the current page that we're on. AncestorsOrSelf is all of the ancestors this page has in the tree. (level) means: go up to level 1/2/3/... and stop looking for more ancestors when you get there.

### As you can see in the example below, the level gets on increasing - level + 1. so, it starts by 1 and then just go on adding 1 to your sub levels.
```
- Content
 -- Home (level = 1)
   -- About Us (level = 2)
   -- Contact Us (level = 2)
   -- News Area (level = 2)
     -- News Item 1 (level = 3)
     -- News Item 2 (level = 3)
 -- Other Node (level = 1)
```
## So when you mention 3 as parameter for AncestorOrSelf, you are asking to move to 3rd level in the tree from the current element that can be any document/partial view and stop looking for any more ancestors when its found. 
It is basically for fetching ancestors by level, doesn't matter what your current level or currentpage object is.

## `For example`, if you want to create a navigation in your main layout so as to share it on all pages of your site, you will do something like this in your template:
```
<ul>
 @foreach(var page in @CurrentPage.AncestorOrSelf(1).Children)
 {
   <li><a href="@page.Url">@page.Name</a></li>
 }
</ul>
```
# Day 3 `(8/Feb/2023)`

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


# Day 4 `(9/Feb/2023)`

# Take a look on `how to make an element that can have multiple paragraph` -->[(Block List Editor)](https://www.youtube.com/watch?v=lqWoNf27hyc&list=PL90L_HquhD-81xTOCLLJZLl1roU6hXPhp&index=9)

# Take a look on `the document of Umbraco with PetaPoco` -->[(Block List Editor)](# Take a look on `how to make an element that can have multiple paragraph` -->[(Umbraco with Database)](https://www.youtube.com/watch?v=lqWoNf27hyc&list=PL90L_HquhD-81xTOCLLJZLl1roU6hXPhp&index=9)
)

# Day 5 `(10/Feb/2023)`

## Take a look on `how to make a component that contain a form input` -->[(Block List Editor)](https://www.bing.com/videos/search?q=umbraco+10+why+Component+folder+is+not+visible&&view=detail&mid=C43F5BDAE01200EFF6B0C43F5BDAE01200EFF6B0&&FORM=VRDGAR&ru=%2Fvideos%2Fsearch%3Fq%3Dumbraco%2B10%2Bwhy%2BComponent%2Bfolder%2Bis%2Bnot%2Bvisible%26FORM%3DHDRSC4)

# Working on `PetaPoco` [Check out the docs](https://github.com/CollaboratingPlatypus/PetaPoco/wiki/Ways-to-instantiate-PetaPoco):

## Setting up the connection string:
```
// Fluent configuration constructor
public Database(IBuildConfiguration configuration)

// Traditional constructors
public Database(IDbConnection connection, IMapper defaultMapper = null)
public Database(string connectionString, string providerName, IMapper defaultMapper = null)
public Database<TDatabaseProvide>(string connectionString, IMapper defaultMapper = null)
public Database(string connectionString, DbProviderFactory factory, IMapper defaultMapper = null)
public Database(string connectionString, IProvider provider, IMapper defaultMapper = null)
```
### The used method in the project is `public Database(string connectionString, IProvider provider)`
Example:
```
    var db = new PetaPoco.Database("Data Source=example\...;User ID=name;Password=password;Initial Catalog= DBName;","Microsoft.Data.SqlClient");
    
    ---or---

    var connectionString = @"Data Source=example\...;User ID=name;Password=password;Initial Catalog= DBName;";
    var provider = @"Microsoft.Data.SqlClient";
    var db = new PetaPoco.Database(connectionString,provider);
```


# Creating form input in Umbraco 10 [Check this document](https://docs.umbraco.com/v/10.x-lts/umbraco-cms/fundamentals/code/creating-forms) 
# Gettin data from form submit:
## To get started we need `ViewModel` Class Object in `Models` folder inside project `Example`:
```
namespace SecondCMS.Models.pocos
{
    [TableName("Users")]
    [PrimaryKey("ID",AutoIncrement =true)]
    [ExplicitColumns]
    public class UserViewModel
    {
        public int ID { get; set; }
        public string? Name { get; set; }
        /*public string Email { get; set; }*/
        public string? Password { get; set; }
    }
}

```
# Then we need a View Creating the view for the form to the `/View/Partials` folder. Because we've added the `model` and built the solution we can add it as a strongly typed `view`. Name your view `"SignUpForm"`.The view can be built with standard MVC helpers:
```
@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage
@using SecondCMS.Models.pocos;
@using SecondCMS.Controllers;
@{
    var user = new UserViewModel();
}

@using (Html.BeginUmbracoForm<SignUpController>(nameof(SignUpController.Submit)))
{
    <div class="input-group">
            <label asp-for="@user.Name"></label>
            <input asp-for="@user.Name" />
    </div>
    <div>
            <label asp-for="@user.Password"></label>
            <input asp-for="@user.Password" />
    </div>
    <div>
            <label name="Confirm Password"></label>
            <input name="confirm"></input>
    </div>
    <br/>
    <input type="submit" name="Submit" value="Sign up" />
}
```
# `Note` to access the `ViewModel` values we must use `@using SecondCMS.Models...` 

## Then we need the controller we have to create a folder `Controllers` inside the root directory and we can add a class `ExampleController` Controller suffix is needed. `Example`:
```

namespace SecondCMS.Controllers
{
    public class SignUpController : Umbraco.Cms.Web.Website.Controllers.SurfaceController
    {
        [HttpPost]
        [ValidateUmbracoFormRouteString]
        public IActionResult Submit(UserViewModel user)
        {
            var db = new PetaPoco.Database(connectionString, provider);
            //var users = db.Query<UserViewModel>("SELECT * FROM Users");
            db.Save("Users","ID",user);
            db.Dispose();
            return RedirectToCurrentUmbracoUrl();
            //return RedirectToCurrentUmbracoPage();
            //return "Result : Username = " + user.Name;
        }
    }
}

```


## `Note` the controllers must
