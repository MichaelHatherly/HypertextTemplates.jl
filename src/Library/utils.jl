function merge_attrs(component_attrs::NamedTuple, user_attrs)
    component_class = get(component_attrs, :class, "")
    user_class = get(user_attrs, :class, "")

    # Merge all attributes, with user attributes taking precedence except for class
    merged_nt = merge(component_attrs, user_attrs)

    # Special handling for class - component classes come first
    if !isempty(component_class) || !isempty(user_class)
        merged_class = if isempty(user_class)
            component_class
        elseif isempty(component_class)
            user_class
        else
            "$component_class $user_class"
        end
        return merge(merged_nt, (; class = merged_class))
    else
        return merged_nt
    end
end
