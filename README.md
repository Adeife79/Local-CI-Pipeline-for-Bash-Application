# Assignment 3: Local CI/CD with GitHub Actions

This project provides a small Bash command-line tool and a local CI pipeline. It validates Bash syntax, runs application tests, then builds and smoke-tests a Docker image without the application being deployed to a cloud service.

## Commands

```bash
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port localhost 80
./app/app.sh help
```

Invalid commands or arguments exit with status `2`. Host lookup and TCP connection failures return a non-zero status. TCP checks time out after three seconds.

## Local validation

```bash
./scripts/lint.sh
./tests/test.sh
./scripts/build.sh
```

Alternatively, use Docker Compose to build and run the help command:

```bash
docker compose run --build --rm devops-tool
```

## CI failure demonstration

To demonstrate a failing workflow, create a temporary branch, introduce a Bash syntax error or a deliberately failing test, and push the branch. The `validate` or `test` job will fail and prevent downstream jobs from running. Revert the deliberate failure and push again; the final workflow should pass. No deployment is configured.
