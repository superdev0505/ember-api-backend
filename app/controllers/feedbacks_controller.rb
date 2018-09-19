class FeedbacksController < ApplicationController
  include JSONAPI::ActsAsResourceController


  # Generate a PDF report based on given start and end dates and send to the user
  def download_report

    entry_ids = []
    # Updated app states whether to select all or none by default
    if params[:select_all] && params[:select_all] == 'true'
      # Return everything except those which are in all_logbook_entry_ids but not in logbook_entry_ids
      # i.e. loaded in the Ember app but not selected
      entry_ids = current_user.logbook_entries.select('id').all.collect{|a| a.id}
      unless params[:logbook_entry_ids].blank? || params[:all_logbook_entry_ids].blank?
        params[:all_logbook_entry_ids].each do |lid|
          if !params[:logbook_entry_ids].include?(lid)
            entry_ids.delete(lid.to_i)
          end
        end
      end
    else
      # LEGACY CODE - included for compatibility with old Ember app version
      entry_ids = params[:logbook_entry_ids] unless params[:logbook_entry_ids].blank?
    end
    if entry_ids.empty?
      render text: "Please select some logs to download."
      return
    end
    @logbook_entries = LogbookEntry.find(entry_ids)

    if @logbook_entries.empty?
      render text: "Please select some logs to download."
    else
      ExportCertJob.perform_later(current_user, entry_ids)

      render text: "Downloading report. You will receive an email to #{current_user.email} within a few minutes."
    end
  end
end
