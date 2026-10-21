json.success true
json.message message ||= "Update successfully"

json.data do
  json.user do
    json.partial! "users/user", user: current_user
  end

  if defined?(@xaman_info) && @xaman_info.present?
    json.xaman_account_info @xaman_info
  end
end
