require 'rdiscount'

module ApplicationHelper
  def render_page_title
    page_title = content_for(:page_title)
    page_title = 'Welcome' if page_title.blank?
    # using content_for to set :page_title means it's already been escaped.
    %Q{#{page_title} :: Vestibule}.html_safe
  end

  def page_title(new_page_title)
    content_for :page_title do
      new_page_title
    end
    content_tag :h1, new_page_title
  end

  def remind_account_for_signup_reason
    current_user && !current_user.signup_reason.present? && !request.path[/user/]
  end

  def avatar_url(user)
    size = "n"
    "http://img.tweetimag.es/i/#{user.twitter_nickname}_#{size}"
  end

  def markdown(text)
    if text
      markdown = RDiscount.new(text)
      markdown.to_html.html_safe
    else
      nil
    end
  end

  def proposal_title_for_rss(for_proposal)
    %{"#{h for_proposal.title}" by #{proposer_name_for_rss(for_proposal.proposer)}}.html_safe
  end

  def proposer_name_for_rss(for_proposer)
    %{#{h for_proposer.name} (@#{h for_proposer.twitter_nickname})}.html_safe
  end
end
