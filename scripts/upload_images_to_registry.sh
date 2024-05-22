if [ "$#" -ne 1 ]; then
    echo "./download_images.sh <local directory> <registry URL>"
fi


C=$(pwd)
IN=$1
REGISTRY=$2

docker login $REGISTRY

for item in $(ls $IN/honeyo); do
    docker load < $IN/honeyo/$item;
done

for item in $(docker image ls | grep honeyo | awk '{print $1}'); do
    docker tag $item $REGISTRY/$item;
    docker push $REGISTRY/$item;
done

for item in $(ls $IN/ms); do
    docker load < $IN/ms/$item;
done

for item in $(docker image ls | grep ms | awk '{print $1}'); do
    docker tag $item $REGISTRY/$item;
    docker push $REGISTRY/$item;
done


cd $C