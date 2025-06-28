function merge_attrs(component_attrs::NamedTuple, user_attrs)
    # Convert both to dicts for easier manipulation
    component_dict = Dict{Symbol,Any}(pairs(component_attrs))
    user_dict = Dict{Symbol,Any}(user_attrs...)

    # Extract classes
    component_class = get(component_dict, :class, "")
    user_class = get(user_dict, :class, "")

    # Merge all attributes, with user attributes taking precedence except for class
    merged_dict = merge(component_dict, user_dict)

    # Special handling for class - component classes come first
    if !isempty(component_class) || !isempty(user_class)
        merged_class = if isempty(user_class)
            component_class
        elseif isempty(component_class)
            user_class
        else
            "$component_class $user_class"
        end
        merged_dict[:class] = merged_class
    end

    # Convert back to named tuple for splatting
    return (; pairs(merged_dict)...)
end
