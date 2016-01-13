# Alki

## Setup

Requires Ruby 2.2.3 and Postgres.

### Environment

Alki uses the following environment variables for configuration:

- TRELLO_KEY, TRELLO_SECRET for communicating with the Trello API.
- SECRET for the cookie secret.
- DATABASE_URL to connect to the Postgres database.

A sample .envrc file is available [here](https://drive.google.com/open?id=0ByzPAU4fK2-EZTJFMVdsM1gweWc).

### Database

```
createdb alki
rake db:migrate
```

## Pushing to Cloud Foundry

```
cf push
```

## Development

```
bundle install
```

To run the development server:

If postgres is running: `rerun --no-notify -- rackup`

Otherwise, `foreman start -f Procfile.dev`

### Running the tests

Database setup:

```
createdb alki_test
DATABASE_URL=postgres://localhost/alki_test rake db:migrate
```

To actually run the tests:

```
rake
```

### Jasmine

Open file://<repo root>/test/jasmine/SpecRunner.html in a browser.