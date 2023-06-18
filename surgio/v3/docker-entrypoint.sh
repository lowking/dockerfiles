#!/bin/sh
set -e
targetBranch=$1
if [ -n "$REPO_BRANCH" ]; then
    targetBranch="$REPO_BRANCH"
fi
if [ -z "$targetBranch" ]; then
    targetBranch="master"
fi

echo -e "$KEY" >/root/.ssh/id_ed25519
if [ -f ./surgio-id-rsa ]; then
    echo "█使用仓库中的ssh key"
    cp -f ./surgio-id /root/.ssh/id_ed25519
fi
chmod 600 /root/.ssh/id_ed25519

cloneRepo() {
    repoName=$1
    repoUrl=$2
    branchName=$3
    if [ ! -d "/${repoName}/.git" ]; then
        echo "█未检查到${repoName}仓库，clone..."
        rm -fr /"${repoName}"
        git clone "${repoUrl}" /"${repoName}"
        git -C "/${repoName}" fetch --all
        git -C "/${repoName}" checkout "${branchName}"
    else
        echo "█更新${repoName}仓库..."
        git -C "/${repoName}" fetch --all
        git -C "/${repoName}" checkout "${branchName}"
        git -C "/${repoName}" reset --hard origin/"${branchName}"
        git -C "/${repoName}" pull origin "${branchName}" --rebase
    fi
}

ssh-keyscan "$REPO_DOMAIN" > /root/.ssh/known_hosts
cloneRepo surgio "$REPO_URL" "$targetBranch"

cp -f ./docker-entrypoint.sh /usr/local/bin

#npm config delete registry
#npm config set registry http://registry.npmjs.org
npm install

touch /surgio/nohup.out
sh start.sh
