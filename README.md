## Usage
1. Clone the project
2. Move your Pterodactyl panel code into the `./files/` directory
3. Make sure the `.env` file is set up to work locally. The MySQL password is just `PASSWORD`.
4. Start the project with `./start.sh` which will build the image and start the Docker Compose project.

---

## Using xDebug
You can set up xDebug in your IDE to listen on port 9000/9003.

In IntelliJ, this is what I recommend:

![img](https://i.geri.dev/xOtAuQLZa8S4.png)
![img](https://i.geri.dev/lYc9nbC6idvI.png)

---

## Useful Commands

- Create a user: `docker exec -it pterodactyl-panel-1 php artisan p:user:make`
- Get panel logs: `docker logs --follow pterodactyl-panel-1`