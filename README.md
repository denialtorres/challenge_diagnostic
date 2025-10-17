# Documentation

## How to mount the project
### Docker
To mount the project inside the main folder:
run

```shell
docker-compose up --build
```

For run the migrations
```shell
 docker-compose exec app rails db:migrate
```
Run the seed files

```shell
docker-compose exec app rails db:seed
```

to run the server
```shell
docker-compose exec app rails server -b 0.0.0.0
```

to run the tests
```shell
docker-compose exec app /bin/bash
rails db:environment:set RAILS_ENV=test
RAILS_ENV=test bundle exec rspec
```

access to the shell
```shell
docker-compose exec app /bin/bash
```

to access to the rails console
```shell
docker-compose exec app rails c
```
