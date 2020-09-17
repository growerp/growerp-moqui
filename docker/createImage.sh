#!/bin/bash
set -x

rm -rf moqui
echo "download from repository"
git clone https://github.com/growerp/moqui-framework.git moqui && cd moqui
./gradlew getRuntime
git clone https://github.com/growerp/GrowERP-Mobile.git runtime/component/backend
rm -rf runtime/backend/templateWebsite
git clone https://github.com/growerp/PopCommerce.git runtime/component/PopCommerce
git clone https://github.com/growerp/mantle-udm.git runtime/component/mantle-udm
git clone https://github.com/growerp/mantle-usl.git runtime/component/mantle-usl
git clone https://github.com/growerp/SimpleScreens.git runtime/component/SimpleScreens
git clone https://github.com/growerp/moqui-fop.git runtime/component/moqui-fop
curl -L https://jdbc.postgresql.org/download/postgresql-42.2.9.jar -o runtime/lib/postgresql-42.2.9.jar
./gradlew addRunTime
cd ..
rm -rf buildImage && mkdir buildImage && cp Dockerfile buildImage && cd buildImage
if unzip -q ../moqui/moqui-plus-runtime.war; then
    echo "downloaded and build successfully"
else
    echo "compile/build failed"
    exit
fi
exit
# adjust for creating the image in hub.docker.com
echo "building image...."
docker logout # avoid uploading to docker hub when building
docker build -t $DOCKERHUBACCOUNT/$DOCKERHUBPROJECT .
docker tag $DOCKERHUBACCOUNT/$DOCKERHUBPROJECT $DOCKERHUBACCOUNT/$DOCKERHUBPROJECT:$DATE
echo "push image to $DOCKERHUBACCOUNT/$DOCKERHUBPROJECT"
if docker login -u $DOCKERHUBACCOUNT -p $DOCKERHUBPASSWORD ; then
    if docker push $DOCKERHUBACCOUNT/$DOCKERHUBPROJECT ; then
        cd ..
        rm -rf moqui; rm -rf buildImage
        docker rmi -f $(docker images -q)
        echo "image pushed to docker hub"
        exit
    fi
fi
echo "something went wrong?"


