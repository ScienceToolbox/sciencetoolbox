json.tool do
  json.(@tool, :id, :url, :name, :created_at, :updated_at, :description,
    :doi, :metadata, :test, :virtualization, :license, :readme, :ci,
    :reproducibility_score)

  json.citations @tool.citations do |citation|
    json.title citation.title
    json.doi citation.doi
  end
end
