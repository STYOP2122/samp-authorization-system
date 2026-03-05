#include <a_samp>
#include <a_mysql>

// ==================== Конфиг ====================
#define MYSQL_HOST      "127.0.0.1"
#define MYSQL_USER      "root"
#define MYSQL_PASS      ""
#define MYSQL_DB        "portfolio_samp"

#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

#define MIN_PASSWORD_LEN 4
#define MAX_PASSWORD_LEN 32
#define SALT_LEN         16

#define SPAWN_X          1958.3783
#define SPAWN_Y          1343.1572
#define SPAWN_Z          15.3746
#define SPAWN_A          269.1425

// ==================== Переменные ====================
new MySQL:g_MySQL;
new g_PlayerLogged[MAX_PLAYERS];
new g_PlayerAccountID[MAX_PLAYERS];

// ==================== Вспомогательные ====================
stock GenerateSalt(dest[], maxlen) {
	new chars[] = "0123456789abcdef";
	new i = 0;
	while (i < SALT_LEN && i < maxlen - 1) {
		dest[i] = chars[random(sizeof(chars) - 1)];
		i++;
	}
	dest[i] = '\0';
}

// ==================== MySQL Callbacks ====================
forward OnCheckAccount(playerid);
public OnCheckAccount(playerid) {
	if (!IsPlayerConnected(playerid)) return 0;
	new rows = cache_num_rows();
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));

	new body[256];
	if (rows > 0) {
		format(body, sizeof(body), "Добро пожаловать, %s.\nВведите пароль:", name);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
			"Вход", body, "Войти", "Выход");
	} else {
		format(body, sizeof(body), "Никнейм \"%s\" свободен.\nВведите пароль (от %d до %d символов):",
			name, MIN_PASSWORD_LEN, MAX_PASSWORD_LEN);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
			"Регистрация", body, "Зарегистрировать", "Выход");
	}
	return 1;
}

forward OnLoginDone(playerid);
public OnLoginDone(playerid) {
	if (!IsPlayerConnected(playerid)) return 0;
	if (cache_num_rows() == 0) {
		SendClientMessage(playerid, 0xFF0000FF, "Неверный пароль.");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
			"Вход", "Введите пароль:", "Войти", "Выход");
		return 1;
	}
	cache_get_value_name_int(0, "id", g_PlayerAccountID[playerid]);
	g_PlayerLogged[playerid] = 1;

	mysql_format(g_MySQL, g_QueryBuf, sizeof(g_QueryBuf),
		"UPDATE accounts SET last_login = NOW() WHERE id = %d", g_PlayerAccountID[playerid]);
	mysql_pquery(g_MySQL, g_QueryBuf);

	SpawnPlayer(playerid);
	SendClientMessage(playerid, 0x00FF00FF, "Вы успешно вошли в аккаунт.");
	return 1;
}

forward OnRegisterDone(playerid);
public OnRegisterDone(playerid) {
	if (!IsPlayerConnected(playerid)) return 0;
	g_PlayerAccountID[playerid] = cache_insert_id();
	g_PlayerLogged[playerid] = 1;
	SpawnPlayer(playerid);
	SendClientMessage(playerid, 0x00FF00FF, "Аккаунт создан. Добро пожаловать!");
	return 1;
}

// Буфер для запросов
new g_QueryBuf[320];

// ==================== Основные колбэки ====================
main() {
	print("\n========================================");
	print(" Portfolio Mod — MySQL Auth");
	print("========================================\n");
}

public OnGameModeInit() {
	g_MySQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
	if (g_MySQL == MYSQL_INVALID_HANDLE) {
		print("[MySQL] Ошибка подключения к БД. Проверьте конфиг и сервер MySQL.");
		SendRconCommand("exit");
		return 0;
	}
	mysql_set_charset("utf8mb4", g_MySQL);
	mysql_log(ERROR | WARNING);
	print("[MySQL] Подключение успешно.");

	SetGameModeText("Portfolio RP");
	AddPlayerClass(0, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit() {
	if (g_MySQL != MYSQL_INVALID_HANDLE)
		mysql_close(g_MySQL);
	return 1;
}

public OnPlayerConnect(playerid) {
	g_PlayerLogged[playerid] = 0;
	g_PlayerAccountID[playerid] = 0;

	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));

	mysql_format(g_MySQL, g_QueryBuf, sizeof(g_QueryBuf),
		"SELECT id FROM accounts WHERE name = '%e' LIMIT 1", name);
	mysql_pquery(g_MySQL, g_QueryBuf, "OnCheckAccount", "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	g_PlayerLogged[playerid] = 0;
	g_PlayerAccountID[playerid] = 0;
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if (!response) {
		SendClientMessage(playerid, 0xC0C0C0FF, "Вы вышли из диалога.");
		Kick(playerid);
		return 1;
	}

	switch (dialogid) {
		case DIALOG_LOGIN: {
			if (strlen(inputtext) < MIN_PASSWORD_LEN) {
				SendClientMessage(playerid, 0xFF0000FF, "Пароль слишком короткий.");
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
					"Вход", "Введите пароль:", "Войти", "Выход");
				return 1;
			}
			new name[MAX_PLAYER_NAME];
			GetPlayerName(playerid, name, sizeof(name));
			mysql_format(g_MySQL, g_QueryBuf, sizeof(g_QueryBuf),
				"SELECT id FROM accounts WHERE name = '%e' AND pass = SHA2(CONCAT('%e', salt), 256) LIMIT 1",
				name, inputtext);
			mysql_pquery(g_MySQL, g_QueryBuf, "OnLoginDone", "i", playerid);
		}
		case DIALOG_REGISTER: {
			new len = strlen(inputtext);
			if (len < MIN_PASSWORD_LEN || len > MAX_PASSWORD_LEN) {
				SendClientMessage(playerid, 0xFF0000FF, "Пароль должен быть от 4 до 32 символов.");
				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
					"Регистрация", "Введите пароль (4-32 символа):", "Зарегистрировать", "Выход");
				return 1;
			}
			new name[MAX_PLAYER_NAME], salt[SALT_LEN + 1];
			GetPlayerName(playerid, name, sizeof(name));
			GenerateSalt(salt, sizeof(salt));
			mysql_format(g_MySQL, g_QueryBuf, sizeof(g_QueryBuf),
				"INSERT INTO accounts (name, salt, pass) VALUES ('%e', '%s', SHA2(CONCAT('%e', '%s'), 256))",
				name, salt, inputtext, salt);
			mysql_pquery(g_MySQL, g_QueryBuf, "OnRegisterDone", "i", playerid);
		}
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
	SetPlayerCameraPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z + 1.0);
	SetPlayerCameraLookAt(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
	return 1;
}

public OnPlayerSpawn(playerid) {
	if (!g_PlayerLogged[playerid]) {
		Kick(playerid);
		return 0;
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
	if (strcmp("/q", cmdtext, true, 2) == 0 || strcmp("/quit", cmdtext, true, 5) == 0) {
		SendClientMessage(playerid, 0xC0C0C0FF, "До встречи.");
		Kick(playerid);
		return 1;
	}
	if (strcmp("/stats", cmdtext, true, 6) == 0) {
		if (!g_PlayerLogged[playerid]) return 0;
		new str[128], name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof(name));
		format(str, sizeof(str), "Аккаунт: %s | ID в БД: %d", name, g_PlayerAccountID[playerid]);
		SendClientMessage(playerid, 0x00AAFFFF, str);
		return 1;
	}
	return 0;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle) {
	printf("[MySQL Error] id=%d callback=%s error=%s", errorid, callback, error);
	return 0;
}
