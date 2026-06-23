## Source code of the Support mod used in Shield Client
- ### Has a lot of stuff like fixes, patches, and more (server browser, friends/party, chat fixes, etc)

## How to Compile, Either:
- ### Download the latest Shield Client update [here](https://github.com/NotNierPea/shield-launcher), and Extract it in bo4 directory.
- ### Go to ``project-bo4/internals``, move ``T8ShieldSupport`` to ``project-bo4/mods``.

#### OR

- ### Use the ``shield-support-mod/ShieldConfig/project-bo4/mods/T8ShieldSupport`` and copy it to bo4 directory: ``project-bo4/mods``.
- ### Also make sure that the old ``T8ShieldSupport`` does not exists in ``project-bo4/internals`` or it will cause a crash.

----

- ### Then you can modify anything here in this project, and run ``compile_and_copy_lua.bat`` for lua files or ``compile_and_copy_scripts.bat`` for gsc/csc files (if in VSCode, you can run the tasks instead)
