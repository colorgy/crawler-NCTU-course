require_relative './nctu_course.rb'
require 'pry'

require 'thread'
require 'thwait'

class NctuCourseCrawler

  PERIODS = {
    "M" => 0,
    "N" => 1,
    "A" => 2,
    "B" => 3,
    "C" => 4,
    "D" => 5,
    "X" => 6,
    "E" => 7,
    "F" => 8,
    "G" => 9,
    "H" => 10,
    "Y" => 11,
    "I" => 12,
    "J" => 13,
    "K" => 14,
    "L" => 15,
  }

  def initialize year: current_year, term: current_term, update_progress: nil, after_each: nil, params: nil

    @year = params && params["year"].to_i || year
    @term = params && params["term"].to_i || term
    @update_progress_proc = update_progress
    @after_each_proc = after_each

  end

  def courses
    @courses = []
    cc = NctuCourse.new(year: @year, term: @term)

    @threads = []
    cc.departments.keys.each do |unit_id|
      sleep(1) until (
        @threads.delete_if { |t| !t.status };  # remove dead (ended) threads
        @threads.count < (ENV['MAX_THREADS'] || 25)
      )
      @threads << Thread.new do
        @courses.concat cc.get_course_list(unit_id: unit_id)
        # binding.pry
      end
    end

    ThreadsWait.all_waits(*@threads)

    # normalize course
    @courses.uniq.map do |old_course|
      old_course = Hashie::Mash.new old_course

      year = old_course.acy
      term = old_course.sem

      # normalize time location
      course_days = []
      course_periods = []
      course_locations = []
      old_course.cos_time.split(',').each do |tim_loc|
        tim_loc.match(/(?<d>\d)(?<ps>[#{PERIODS.keys.join}]+)\-?(?<loc>.+)/) do |m|
          m[:ps].split('').each do |p|
            course_days << m[:d].to_i
            course_periods << PERIODS[p]
            course_locations << m[:loc]
          end
        end
      end

      department_code = "#{old_course.degree}#{old_course.dep_id}"

      course = {
        year: year,
        term: term,
        code: "#{year}-#{term}-#{old_course.cos_code}",
        general_code: old_course.cos_code,
        url: old_course.URL,
        name: old_course.cos_cname,
        credits: old_course.cos_credit,
        department: old_course.dep_cname,
        department_code: department_code,
        required: old_course.cos_type.include?('必'),
        day_1: course_days[0],
        day_2: course_days[1],
        day_3: course_days[2],
        day_4: course_days[3],
        day_5: course_days[4],
        day_6: course_days[5],
        day_7: course_days[6],
        day_8: course_days[7],
        day_9: course_days[8],
        period_1: course_periods[0],
        period_2: course_periods[1],
        period_3: course_periods[2],
        period_4: course_periods[3],
        period_5: course_periods[4],
        period_6: course_periods[5],
        period_7: course_periods[6],
        period_8: course_periods[7],
        period_9: course_periods[8],
        location_1: course_locations[0],
        location_2: course_locations[1],
        location_3: course_locations[2],
        location_4: course_locations[3],
        location_5: course_locations[4],
        location_6: course_locations[5],
        location_7: course_locations[6],
        location_8: course_locations[7],
        location_9: course_locations[8],
      }
      @after_each_proc.call(course: course) if @after_each_proc
      course
    end
  end

  def current_year
    (Time.now.month.between?(1, 7) ? Time.now.year - 1 : Time.now.year)
  end

  def current_term
    (Time.now.month.between?(2, 7) ? 2 : 1)
  end
end

# cc = NctuCourseCrawler.new(year: 2014, term: 1)
# File.write('courses.json', JSON.pretty_generate(cc.courses))
