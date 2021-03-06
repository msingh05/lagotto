json.meta do
  json.status "ok"
  json.set! :"message-type", "work_type"
  json.set! :"message-version", "6.0.0"
end

json.work_type do
  json.cache! ['v6', @work_type], skip_digest: true do
    json.(@work_type, :id, :title, :container, :timestamp)
  end
end
