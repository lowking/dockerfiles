apk add --no-cache gcc \
    musl-dev

pip3 install -U git+https://github.com/milkice233/efb-qq-slave
pip3 install -U wheel
#go-cqhttp
pip install git+https://github.com/XYenon/efb-qq-plugin-go-cqhttp

# opq
#pip3 install git+https://github.com/milkice233/efb-qq-plugin-iot

if [ "$PERFIX" ]; then
    sed -i "s/channel_emoji = \"💬\"/channel_emoji = \"$PERFIX\"/g" /usr/lib/python3.9/site-packages/efb_wechat_slave/__init__.py
else
    sed -i 's/channel_emoji = "💬"/channel_emoji = "𝙒𝙚𝙘𝙝𝙖𝙩"/g' /usr/lib/python3.9/site-packages/efb_wechat_slave/__init__.py
fi

sed -i "s/{self.chat_type_emoji}/丨/g" /usr/lib/python3.9/site-packages/efb_telegram_master/chat.py
sed -i "s/?mod=desktop//g" /usr/lib/python3.9/site-packages/efb_wechat_slave/vendor/itchat/components/login.py
