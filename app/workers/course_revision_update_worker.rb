# frozen_string_literal: true
require "#{Rails.root}/lib/course_revision_updater"

class CourseRevisionUpdateWorker
  include Sidekiq::Worker

  def self.schedule_revision_import(course:)
    perform_async(course.id)
  end

  def perform(course_id)
    course = Course.find(course_id)
    course.update_attribute(:needs_update, false)
    return if course.students.empty?
    CourseRevisionUpdater.new(course).update_revisions_for_relevant_wikis
    ArticlesCourses.update_from_course(course)
  end
end
