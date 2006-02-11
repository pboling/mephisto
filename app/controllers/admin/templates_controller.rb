class Admin::TemplatesController < Admin::BaseController
  cache_sweeper :template_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }
  before_filter :select_template, :except => :index

  def index
    redirect_to :controller => 'design'
  end

  def update
    saved = @tmpl.update_attributes(params[:template])
    case
      when request.xhr?
        render :partial => 'form', :locals => { :template => @tmpl }
      
      when saved
        flash[:notice] = "#{@tmpl.name} updated."
        redirect_to :action => 'edit', :id => @tmpl
    
      else
        render :action => 'edit'
    end
  end

  protected
  # @template var clashes with ActionView instance, so use @tmpl
  # Selects all templates for sidebar
  # Create system template if it does not exist
  def select_template
    @templates = Template.find :all
    @tmpl      = @templates.detect { |t| t.name == params[:id] }
    @tmpl    ||= Template.find_or_create_by_name(params[:id]) if Template.template_types.include?(params[:id].to_sym)
  end
end
