script_name('Med')
script_author('akionka')
script_version('1.4')
script_version_number(5)

local sampev   = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg   = require('inicfg')
local dlstatus = require('moonloader').download_status
encoding.default = 'cp1251'
u8 = encoding.UTF8

local med = false
local updatesavaliable = false

local ini = inicfg.load({
  settings = {
    invex = true
  }
}, "med")

function sampev.onShowDialog(id, _, _, _, _, text)
  if id == 1000 and med then
    local i = 0
    for item in text:gmatch("[^\r\n]+") do
      i = i + 1
      if item:find(u8:decode("Аптечка")) ~= nil then
        sampSendDialogResponse(id, 1, i-1, "")
        return false
      end
    end
    sampAddChatMessage(u8:decode("[MED]: {FF0000}Error!{FFFFFF} В инвентаре отсутствуют аптечки. Купить их можно в {2980b9}/gps 11{FFFFFF}."), -1)
    sampSendDialogResponse(id, 0, 0, "")
    med = false
    return false
  end
  if id == 1001 and med then
    sampSendDialogResponse(id, 1, 5, "")
    med = false
    return false
  end
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
  sampAddChatMessage(u8:decode("[MED]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}."), -1)

  checkupdates('https://raw.githubusercontent.com/Akionka/med/master/version.json')

  sampRegisterChatCommand("medinv", function()
    ini.settings.invex = not ini.settings.invex
    inicfg.save(ini, "med")
    sampAddChatMessage(ini.settings.invex and u8:decode("[MED]: Скрипт теперь работает с {2980b9}/invex{FFFFFF}.") or u8:decode("[MED]: Скрипт теперь работает с {2980b9}/inv{FFFFFF}."), -1)
  end)

  sampRegisterChatCommand('medupdate', function()
    if updatesavaliable then
      update('https://raw.githubusercontent.com/Akionka/med/master/med.lua')
    end
  end)

  sampRegisterChatCommand('medcheck', function()
    checkupdates('https://raw.githubusercontent.com/Akionka/med/master/version.json')
  end)

  sampRegisterChatCommand("med", function()
    if getCharHealth(PLAYER_PED) == 100 then return true end
    med = true
    sampSendChat(ini.settings.invex and "/invex" or "/inv")
  end)
end

function checkupdates(json)
  local fpath = os.getenv('TEMP')..'\\'..thisScript().name..'-version.json'
  if doesFileExist(fpath) then os.remove(fpath) end
  downloadUrlToFile(json, fpath, function(_, status, _, _)
    if status == dlstatus.STATUSEX_ENDDOWNLOAD then
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'r')
        if f then
          local info = decodeJson(f:read('*a'))
          local updateversion = info.version_num
          f:close()
          os.remove(fpath)
          if updateversion > thisScript().version_num then
            updatesavaliable = true
            sampAddChatMessage(u8:decode("[MED]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..updateversion.."{FFFFFF}."), -1)
            sampAddChatMessage(u8:decode("[MED]: Используйте команду {2980b0}/medupdate{FFFFFF}, чтобы обновиться до последней версии."), -1)
            return true
          else
            updatesavaliable = false
            sampAddChatMessage(u8:decode("[MED]: У вас установлена самая свежая версия скрипта."), -1)
          end
        else
          updatesavaliable = false
          sampAddChatMessage(u8:decode("[MED]: Что-то пошло не так, упс. Попробуйте позже."), -1)
        end
      end
    end
  end)
end

function update(url)
  downloadUrlToFile(url, thisScript().path, function(_, status1, _, _)
    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
      sampAddChatMessage(u8:decode('[MED]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
      sampAddChatMessage(u8:decode('[MED]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
      sampAddChatMessage(u8:decode('[MED]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
      thisScript():reload()
    end
  end)
end
