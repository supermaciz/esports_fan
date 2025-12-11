# EsportsFan

Technical test: cf [instructions](./INSTRUCTIONS.md).

A E-Sports website and newsletter.

Features:
- Custom newsletter


## Run the project

### Prepare the DB

You need a PostgreSQL instance. You can use the _docker-compose.yml_.
```shell
# To create and start the container
$ docker compose up -d postgres

# start thee container
$ docker compose start postgres
```

You can setup the db with:
```shell
$ mix ecto.setup
```
This command will create the database, run the migrations and seed the db with fake users (cf [mix.exs](./mix.exs)).

> [!IMPORTANT]
> The seed script only creates users. It does **not** create NewsletterWorker jobs for thes users. 
> You will need to do this from iex console.

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running the tests


