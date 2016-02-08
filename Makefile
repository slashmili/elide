build-prod:
	docker build  -t elide-build -f docker/build/Dockerfile .
	docker run --rm -it -v "$(PWD):/code" elide-build
	docker build -t elide-prod -f docker/prod/Dockerfile .
