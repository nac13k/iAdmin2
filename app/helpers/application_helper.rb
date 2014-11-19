module ApplicationHelper

  def date_format(date)
    if date
      date.strftime("%d/%m/%Y")
    else
      "- -"
    end
  end

  def date_time_format(date)
    if date
      date.strftime("%d/%m/%Y - %l:%M %p")
    else
      "- -"
    end
  end

end
