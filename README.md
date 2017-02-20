Automatic tests and example chat for Godot Multiplayer API
=

Main Singleton
-
`script/network.gd` contains the main singleton that abstract a little bit from the Multiplayer API allowing for easy developing of client/server applications.

I know, it's a lot of code, but I could not find any other way to have authoritative (safe) server.
See comments in file because a **patch to Godot Engine** is needed for making this really authoritative.
In the file there is also a brief description of how it works.

Chat application.
-
Inside `script/server.gd` and `script/client.gd` there are implementation for chat server and client (_both ~30 lines of code_) using the main singleton.

Tests
-
Inside `script/tests.gd` there will be automatic tests for the multiplayer API in an attempt to keep it safe and regression free.
Please be ensured, that **safe does not mean secure or private**. There is currently no support for encryption so data is plain-text. There are a bunch of network attacks that can fake IP or act as M-t-M those are note dealt with for now.
**The tests are merely for checking engine logic correctness when dealing with RPCs**.

Workarounds
-
To workaround the fact that the multiplayer API cannot be tested in the same scene (I know, crazy!) a workaround is in place where multiple SceneTree(s) are instantiated in the main and then rendered as textures.
You can see the reference code in `script/scenetree_control.gd` and scene in `scene/scenetree_control.gd`. It's a bit hacky but it works
