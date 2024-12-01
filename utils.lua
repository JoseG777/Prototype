local Utils = {}

function Utils.printTable(t)
    if type(t) ~= "table" then
        print("Not a table!")
        return
    end

    for key, value in pairs(t) do
        print("Key:", key, "Value:", value)
    end
end

return Utils