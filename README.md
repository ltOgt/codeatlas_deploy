# CodeAtlas

CodeAtlas is a canvas based tool for program exploration and comprehension.

It was developed during a bachelors thesis to facilitate an online experiment as part of a study on code comprehension, visuo-spatial mental models, spatial code representation and visuo-spatial working memory.
In addition to the canvas based user interface, a traditional tab-based interface was also implemented as a control.

The tool is split into a backend running on a server, and a frontend running in the users web browser.

The backend
- hosts the source code of the program that should be explored and comprehended
- hosts the tasks that participants of the experiment should complete
- runs a Language Server (via LSP) to provide IDE features like
  - semantic syntax highlighting
  - go to definition
  - find all references
- hosts user directories that collect
  - interaction data
  - task results
  - client-server-communication logs
  - canvas / tab data

The frontend
- can be accessed by participants remotely via their browser
- presents the program files in one of two ways
  - as nodes on a canvas with edges showing the lookup paths (go to definition / find all references) 
  - as tabs with the option to split the screen like in traditional IDEs
- presents participants with tasks and collects their solutions

<details>
<summary>
Video Showing CodeAltas Server and Canvas Client with some basic interaction in the client and stdout of the server
</summary>

https://user-images.githubusercontent.com/24209580/209453034-85d856e6-34ba-4b15-9b22-9c3317115d31.mov

</details>



<details>
<summary>
Video Showing CodeAltas Tab based Client with some basic interaction
</summary>

https://user-images.githubusercontent.com/24209580/209453071-ce7bd982-7617-4c2d-b5a1-b399277609eb.mov

</details>


The project was built using [dart](https://dart.dev/) and [flutter](https://flutter.dev/),
and currently only works with the dart language server and a dart/flutter target code base.

# CodeAtlas Deployment Repository

This repository provides most of the files needed to run CodeAtlas in its current form.

## Files
```
- backend/
  - mount/              # You will need to mount this into the docker image
    - operation/        # This folder contains all the files read and generated by the server
      - _endpointLogs/  # Endpoint requests are logged here by the server
      - user/           # User directories go here
        - makeUser.sh   # Use this to generate user directories, the scripts output will give you further info
      - task/           # Contains the tasks that will be shown to users during the experiment
        - task_*.sr     # See github.com/ltOgt/SR-dart for the file format
      - code/           # The code that will be analyzed during the experiment; Currently contains an adjusted version of Flutter Folio (see README.md in that folder)
        - lib/          # All files in this directory will be exposed to the users in the frontend
        - ...           # All other files are documentation, license or needed for the analyzer (dart pub get)
    - analysis_server.dart.snapshot.GOES_HERE   # placeholder for actual analysis_server.dart.snapshot    REQUIRED
    - fullchain.pem.GOES_HERE_FOR_SSL           # placeholder for actual fullchain.pem if you want HTTPS  (e.g. via letsencrypt certbot)
    - privkey.pem.GOES_HERE_FOR_SSL             # placeholder for actual privkey.pem   if you want HTTPS  (e.g. via letsencrypt certbot)
- frontend/
  - codeatlas/          # Serve this as Web Client
    - index.html        # You will need to configure some stuff here
    - ...               # Other files need to be served, but not changed
```

## Server
### Requirements
In addition to the files provided in this repository, you will need:
- `docker` to run the containerized backend
- `flutter` SDK to fetch all dependencies for the `code/`
  - can be installed e.g. via `snap install flutter` on ubuntu, or by following the steps in the [docs](https://docs.flutter.dev/get-started/install)
- `analysis_server.dart.snapshot` which you can get via the `dart` SDK as part of Flutter
    - e.g. installed via `snap`: `~/snap/flutter/common/flutter/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot`
- `fullchain.pem` and `privkey.pem` of your SSL certificate to run the server with `HTTPS` (without these it will use `HTTP`)

### Loading the image
The main docker image can be found under [Releases](https://github.com/ltOgt/codeatlas_deploy/releases).

It can be imported via `docker load -i /your/path/to/codeatlas.tar`.

### Preparing for launch
Once you have a local copy of the `mount/` directory, you will need to
- copy `analysis_server.dart.snapshot` into the `mount/` folder
  - make sure it has execution permissions (e.g. `chmod a+x`)
- copy `fullchain.pem` into the `mount/` folder (to use HTTPS)
  - make sure it has read permissions (e.g. `chmod a+r`)
- copy `privkey.pem` into the `mount/` folder (to use HTTPS)
  - make sure it has read permissions (e.g. `chmod a+r`)
- run `flutter pub get` inside the `code/` directory to get all dependencies the analyzer needs to work properly
  - NOTE: this is also why `analysis_server.dart.snapshot` can not be distributed as part of the docker image; the Dart SDK version used to resolve the dependencies and cache them on your machine needs to match that of the `analysis_server`
- use `cd mount/operation/user/` and then `./makeUser.sh` to create new users as needed
  - run without arguments for more info on how to use that script
  - should be run inside `mount/operation/user/`


### Running the image

If you have loaded the image into your docker, you can run it with

```
docker run --platform linux/amd64 -p <desired_port>:8181 -v <ABSOLUT_PATH_to_mount_dir>:/codeatlas codeatlas:latest
```


## Client

Simply add the `codeatlas/` directory (see `frontend/`) to wherever your HTML is served from.

You can change the name of the `codeatlas/` directory if you want, the following documentation will use this name.

Inside `codeatlas/index.html` you will need to configure some things:

At the top of the file you will find two TODOs:
```html
  ...
  <!-- TODO: FILL THIS OUT -->
  <script defer>
    window.state = {
      // STRING
      domain: "example.com",
      // INT
      port: 8181,
      // BOOL
      ssl: true,
    }
  </script>
  ...
	<!-- TODO: FILL THIS OUT -->
  <base href="/your/path/to/codeatlas/">
  ...
```

The `window.state` tells the client about the domain and port your backend is listening to, and whether you want to use `HTTPS` (recommended).

The `<base href=...` is needed by the flutter web engine to work properly, simply add the path to where you serve the client from (including the potentially changed name of `codeatlas/`)
