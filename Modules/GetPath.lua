local function loopUp(root, node, path)
    if not path and node then
        path = {node.Name}
    end

    local nodeParent = node.Parent
    if nodeParent:IsA('Folder') then
        table.insert(path, 1, nodeParent.Name)
    end

    if nodeParent == root then
        return path
    else
        return loopUp(root, nodeParent, path)
    end
end

return function(root : Folder, instance : Instance, removeRoot : boolean)
    local pathSuccess : table = loopUp(root, instance)
    if removeRoot then
        table.remove(pathSuccess, 1)
    end
    if pathSuccess then
        return table.concat(pathSuccess, '/')
    end
end