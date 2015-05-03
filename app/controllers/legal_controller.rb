class LegalController < ApplicationController
  before_action :set_constants

  def set_constants
    @product = 'TabRehab'
    @law_source = 'California'
    @court_location = 'San Francisco County (CA)'

    @posted = Time.new 2014, 11, 5
    @effective = Time.new 2014, 11, 5
    @dispute_email = 'legal@tabrehab.com'
    @dmca_email = 'legal@tabrehab.com'
    @privacy_email = 'support@tabrehab.com'
  end
  private :set_constants

  SUPPORTED_DOCUMENTS = %w(tos privacy aup dmca)

  # GET /legal
  # GET /legal/x
  def show
    document = params[:document]
    unless SUPPORTED_DOCUMENTS.include? document
      redirect_to legal_url(document: 'tos')
      return
    end
    render action: document
  end
end
