# app/helpers/application_helper.rb
module ApplicationHelper
  # Foto profil dari avatar_url (OAuth). Kalau kosong, tampilkan inisial nama.
  def avatar_for(user, size: "w-9 h-9")
    if user.avatar_url.present?
      image_tag user.avatar_url, alt: user.name, referrerpolicy: "no-referrer",
                class: "#{size} rounded-full object-cover"
    else
      content_tag :span, user.name.to_s.first(1).upcase,
                  class: "#{size} rounded-full bg-emerald-600 text-white " \
                         "flex items-center justify-center font-semibold"
    end
  end

  def sidebar_link(label, path, icon:, active:)
    base  = "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
    state = active ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400"
                   : "text-slate-600 hover:bg-slate-100 dark:text-slate-400 dark:hover:bg-slate-800"

    link_to path, class: "#{base} #{state}" do
      safe_join([ content_tag(:i, "", class: "fa-solid #{icon} w-5 text-center"), label ])
    end
  end
end
