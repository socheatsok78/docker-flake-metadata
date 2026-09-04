it: print
print:
	docker buildx bake --print
build:
	docker buildx bake --print
	docker buildx bake --set="*.platform=" --load
publish:
	docker buildx bake --print
	docker buildx bake --push
list-modules:
	docker run --rm -it $(shell docker buildx bake --print | jq -cr '.target.default.tags[]') caddy list-modules
