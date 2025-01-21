# 사용할 모드: "local" 또는 "remote"
MODE = "remote"

db_config = {
    "local": {
        "host": "127.0.0.1",
        "user": "root",
        "password": "qwer1234",
        "database": "sumartpick",
    },
    "remote": {
        "host": "192.168.50.71",
        "user": "sumartpick",
        "password": "qwer1234",
        "database": "sumartpick",
    },
}


def get_db_config():
    return db_config[MODE]
