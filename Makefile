build-prod: build-img
	docker run -e "MIX_ENV=prod" --rm -it -v "$(PWD):/code" elide-build
	docker build -t elide-prod -f docker/prod/Dockerfile .

build-img:
	docker build  -t elide-build -f docker/build/Dockerfile .

test:
	docker-compose -f docker/test/docker-compose.yml run test mix test

build-doc:
	rm -rf gh-pages
	git clone -b gh-pages git@github.com:slashmili/elide.git gh-pages
	mix docs
	cp -r doc/* gh-pages
	cd gh-pages && git add . && git commit -m "Docs updated at $$(date  +'%Y-%m-%d %H:%M:%S')"
