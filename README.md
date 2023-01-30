# This is for the lavarel project commands from the start:

creating new project command with composer after php and composer:
```
composer create-project laravel/laravel example-app
```
Or, you may create new Laravel projects by globally installing the Laravel installer via Composer:
```
composer global require laravel/installer
 
laravel new example-app
```
After create the project `make sure to the project folder`:
```
cd example-app
 
php artisan serve
```

for details use :
```
php -h or php --help
```

for clear cache db:
```
php artisan config:cache
```
make migration to generate code first to db make sure to use `create_`example_`table` so it will auto-generate schema:
```
php artisan make:migration create_blocks_table
```

# `configure .env file make sure change db name and port `

## First we need to make/create controller to return the view in index function
To create controller with command:
```
php artisan make:controller [example`Controller`]
```

## Migration create database from code first
to create migration file with commands:

### `Note:` to make the generated migration file have pre method you need to use `create_`name`_table`.
```
php artisan make:migration create_example_table
```

To create table from code first we write the property in up function on crated file:

### `Note:` `Schema and Blueprint` is needed
```
public function up()
{
    Schema::create('Topics',function(Blueprint $table)
    {
        $table –> increments('id');
        $table –> string('topicname',100) ->unique();
        $table –> timestamps();
    });
}
```
To delete database:
```
public function down()
{
    Schema::drop('Topics');
    Schema::drop('Blocks');
}
```
After the needed code added to up() and down(). You can perform this command:
### `Note:` this command is needed to push the code to database and create table in database.
```
php artisan migrate
```
If it is necessary to cancel the latest database
modifications, execute the following command:
```
php artisan migrate:rollback
```
If you want to roll back all the changes made to a
database, and then recreate a database, execute the following
command:
```
php artisan migrate:refresh
```
`and execute the migrate command again to recreate the table`

To create the Example model corresponding to the Examples
table command:
```
php artisan make:model Topic
```
After created:
```
<?php
namespace App;
use Illuminate\Database\Eloquent\Model;
class Topic extends Model
{
    protected $primaryKey='id';
    protected $table='topics';
         protected $fillable=['topicname','created_at','updated_at'];
}
```
create the RESTful Controller for working with the Example model:
```
php artisan make:controller ExampleController ––resource 
-or-
php artisan make:controller ExampleController –r
```
Add the following line to the \ExampleProject\routes\web.php file:

`Route::resource('example', 'ExampleController');`

run the command to see all the route that been created:
```
php artisan route:list
```
Of course, there is a number of methods for creating any
form controls:
```
■ Form::label() – creates a label;
■ Form::text() – creates a text field;
■ Form::password() – creates a password entry field;
■ Form::hidden() – creates a hiddent field;
■ Form::file() – creates an element for file selection;
■ Form::radio() – creates a radio button;
■ Form::checkbox() – creates a checkbox;
■ Form::submit() – creates a submit button .
```

## using `passport` as authentication service `(Laravel Sanctum)`



## To use css you need to build the package first by running the command :
`Note:` This will build in `Vite`
```
npm build 
-or-
npm run dev
```

# Middleware (Pre install for laravel version above 5.x.x)
## Route can add auth by adding middleware in route `(web.php)`:
`Route::middleware` is to handle when the user is login or not then redirect to example view
```
Route::middleware('auth')->resource('/path', ClassController::class);
```
`Route::Get` path=login is to redirect to login page
```
Route::get('/login', [LoginController::class, 'index'])->name('login');
```

`Route::Post` login is to handle when submitted form from login page
```
Route::post('/login', [LoginController::class, 'auth'])->name('login.auth');
```
## For the form get submitted and redirect we need to add this Route and method:
```
{!! Form::open(['route' => 'login.auth', 'method' => 'POST']) !!}
``` 
## In the login controller we will need to have auth function that request from the Post method
```
    public function auth(Request $request)
    {
        $cred = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);
        if (Auth::attempt($cred)) {
            $request->session()->regenerate();
            return redirect('topic');
        }
        return back()->withErrors([
            'email'=>'Invalid email or password.'
        ])->onlyInput('email');
    }
```

## To access all errors from session by withErrors() function:

`$error` is php pre-made variable for handling errors into an array of statuses  
```
@if ($errors->any())
    <div class="alert alert-danger">
        @foreach ($errors->all() as $er)
            {{ $er }}<br />
        @endforeach
    </div>
@endif
```