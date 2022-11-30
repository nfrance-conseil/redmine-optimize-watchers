
  module WatchersControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, InstanceMethods)

        alias_method :users_for_new_watcher, :users_for_new_watcher_with_optimize
      end
    end

    module InstanceMethods
      def users_for_new_watcher_with_optimize
        scope = nil

        if @project.present?
          alloweds = @project.assignable_users
        elsif @projects.present? && @projects.size > 1
          alloweds = @projects.map{ |project| @project.assignable_users }.flatten.uniq
        end

        if params[:q].blank?
          if @project.present?
            scope = @project.principals.assignable_watchers
          elsif @projects.present? && @projects.size > 1
            scope = Principal.joins(:members).where(:members => { :project_id => @projects }).assignable_watchers.distinct
          end
        else
          scope = Principal.assignable_watchers.limit(100)
        end

        users = scope.sorted.like(params[:q]).to_a

        if @watchables && @watchables.size == 1
          watchable_object = @watchables.first
          users -= watchable_object.watcher_users

          if @project.present? || (@projects.present? && @projects.size > 1)
            if watchable_object.respond_to?(:visible?)
              users = (users & alloweds) + users.select{|user| user.is_a?(Group) }
            end
            users
          else
            if watchable_object.respond_to?(:visible?)
              users.reject! {|user| user.is_a?(User) && !watchable_object.visible?(user)}
            end
          end
        end
        users
      end
    end
  end
