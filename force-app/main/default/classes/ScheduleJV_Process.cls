/*Schedular class for ND_JV_Process batch class*/
public with sharing class ScheduleJV_Process implements Schedulable {
  private Integer batchSize; // Declare as private

  // Constructor to accept batch size
  public ScheduleJV_Process(Integer batchSize) {
      this.batchSize = batchSize;
  }

  // Ensure execute is not static so it can access the instance variable
  public void execute(SchedulableContext sc) {
      ND_JV_Process u = new ND_JV_Process(); 
      Database.executeBatch(u, batchSize);
  }
}