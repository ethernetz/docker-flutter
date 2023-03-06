# docker-flutter

docker-flutter the perfect ready-to-use flutter dev environment 🥳

inside the container you'll find
- flutter (duh)
- android SDK and a device all ready to go 
- noVNC to see play with the emulator in the broswer

**all this is happening inside a devcontainer 🤯**

<img width="945" alt="image" src="https://user-images.githubusercontent.com/10564713/223031704-57bf1bce-c524-4292-b6f1-875d7ff0b06e.png">


## why would i use this? 
you get a consistent dev environement in 1 command, no matter the host machine 😍

spend 0 seconds trying to set up java, android studio, or flutter 🔥


## getting started

### basic command

by default, docker-flutter will run the `flutter doctor` command to show you everything is working

`docker run -it ethernetz/docker-flutter`

<img width="815" alt="image" src="https://user-images.githubusercontent.com/10564713/223028356-656234a9-03bd-4426-9042-19b6c75c40c7.png">


### dev environment

to set up a dev container, you'll also need to 
- volume mount your project in the `/developer` directory
- forward port `6080`
- add `sleep infinity` at the end to make sure the container stays open once its created

the final command should look like this

`docker run -it -v "$PWD":/developer -p 6080:6080 ethernetz/docker-flutter sleep infinity`

### dev container
flutter-docker even works inside a dev container 

*.devcontainer/devcontainer.json*

```json
{
  "image": "ethernetz/docker-flutter:latest",
  "customizations": {
    "vscode": {
      "extensions": ["Dart-Code.flutter", "Dart-Code.dart-code"]
    }
  },
  "forwardPorts": [6080],
  "runArgs": ["--privileged"]
}
```

## running the emulator

once your dev environment is set up, it just takes 4 commands to see your flutter app in an android emulator

#### start the VNC to the emulator has a display to write to
`Xtigervnc ${DISPLAY} -rfbport ${VNC_PORT} -localhost -SecurityTypes=none`

#### expose the display to the broswer with noVNC 

`/home/developer/noVNC/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NOVNC_PORT}`

#### start the emulator

`/home/developer/start_emulator.sh`

<img width="938" alt="image" src="https://user-images.githubusercontent.com/10564713/223029782-e929a0f0-668a-4ba2-a4e1-6ee53a564bfe.png">


#### once the emulator is ready, start the flutter app! 

`flutter run -d emulator-5554`

<img width="945" alt="image" src="https://user-images.githubusercontent.com/10564713/223031704-57bf1bce-c524-4292-b6f1-875d7ff0b06e.png">


