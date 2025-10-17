# Documentation
## How to Use the app
1 - Go to [demoapp-daniel.fun](https://demoapp-daniel.fun)

2 - in servers select `https://demoapp-daniel.fun/`
<img width="1017" height="352" alt="Screenshot 2025-10-16 at 7 31 07 p m" src="https://github.com/user-attachments/assets/3b766636-6a3e-406d-942d-66c695623a34" />

3 - click in `/v1/auth/login`, then in `Try it Out` and then in `Execute`
<img width="1792" height="1120" alt="Screenshot 2025-10-16 at 7 33 14 p m" src="https://github.com/user-attachments/assets/eaae8564-c71a-4d19-91ff-64d07df44f64" />

4- the response will generate a token
<img width="1433" height="253" alt="Screenshot 2025-10-16 at 7 34 30 p m" src="https://github.com/user-attachments/assets/45cc6ae3-85b3-4f4e-a845-40fc7f3d5389" />

5- copy that token and paste it inside the `Authorize`  input
<img width="1596" height="627" alt="Screenshot 2025-10-16 at 7 35 38 p m" src="https://github.com/user-attachments/assets/a24557fc-08de-452b-b87f-c948cd9a3e1e" />

6 - This will automatically authenticate all the endpoints that require a bearer token
<img width="1539" height="738" alt="Screenshot 2025-10-16 at 7 38 47 p m" src="https://github.com/user-attachments/assets/012392d3-1bdf-449c-b573-c6b60a09801b" />



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

## Technical Decision

### JSON API Serializer Gem Choice

I chose to use the `jsonapi-serializer` gem for this project to implement a clean and standardized API response format following the JSON:API specification. This decision was driven by several key benefits:

**Presenter Pattern Implementation**: The gem naturally implements the presenter pattern, which separates the presentation logic from the business logic. Instead of cluttering models or controllers with serialization concerns, we can create dedicated serializer classes that handle how data is presented to the API consumers.


### Rotulus Gem and Cursor Pagination

I chose to implement cursor pagination using the `rotulus` gem instead of traditional offset-based pagination mostly for:

**Mobile-First Approach**: Cursor pagination is ideal for mobile applications that implement infinite scroll functionality. Unlike offset pagination, cursor pagination maintains consistency even when new records are added to the dataset, preventing duplicate or skipped items during scrolling.


### Swagger for API Documentation

I chose to implement Swagger (OpenAPI) for API documentation to provide a comprehensive and interactive documentation experience:

**Interactive Testing Interface**: Swagger provides a user-friendly web interface that allows developers to test API endpoints directly within the documentation. This eliminates the need for external tools like Postman or curl commands, making it easy to explore and validate API functionality without leaving the browser.

**Self-Documenting API**: I can use the "rswag-specs" gem to generate the documentation based on my rspecs

### Phony Gem for Phone Number Validation

I chose to use the `phony` gem for phone number validation and formatting to ensure consistent and reliable phone number handling:

**Area Code Validation**: The Phony gem provides robust validation based on area codes and country-specific phone number formats.

**Automatic Formatting**: After validation, the gem automatically formats phone numbers into a standardized format for storage.

**International Support**: The gem handles international phone number formats and validation rules,
