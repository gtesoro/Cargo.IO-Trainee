g_player = playdate.datastore.read('player')

if not g_player then
    g_player = {}
    g_player.last_position = {}
    g_player.current_position = {
        x = 0,
        y = 0,
        z = 0
    }
    g_player.money = 1000
    g_player.inventory = {
        items = List(),
        capacity = 9
    }

    g_player.map = {}

    g_player.inventory.items = {}
    g_player.inventory.items[#g_player.inventory.items+1] = Neodymium()
    g_player.inventory.items[#g_player.inventory.items+1] = Scandium()
    g_player.inventory.items[#g_player.inventory.items+1] = Yttrium()
else

    local aux = {}
    for k,v in pairs(g_player.inventory.items) do
        aux[#aux+1] = _G[v.super.className]()
    end

    g_player.inventory.items = aux

end


