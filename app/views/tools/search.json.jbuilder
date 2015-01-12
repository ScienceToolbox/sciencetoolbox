json.search do
  json.array! @tools, partial: 'tool', as: :tool
end
