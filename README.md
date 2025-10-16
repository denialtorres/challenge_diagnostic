## Docker

To mount the project

inside the main foler:

```
docker-compose up --build
```

run the server
```
docker-compose exec app /bin/bash
rails server -b 0.0.0.0
```

run the tests
```
docker-compose exec app /bin/bash
rails db:environment:set RAILS_ENV=test
RAILS_ENV=test bundle exec rspec
```


# Documentation
```
http://localhost:3000/api-docs/
```
