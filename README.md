# claude-code-container


## Push方法

```shell
docker build -t claude-code:latest -f ./Dockerfile .
docker login
docker tag claude-code:latest lemonaderoom/claude-code:latest
docker push lemonaderoom/claude-code:latest
```

bunx playwright install-deps chromium