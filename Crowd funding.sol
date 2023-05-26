// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Project {
        address payable creator;
        string title;
        string description;
        uint256 goalAmount;
        uint256 currentAmount;
        uint256 deadline;
        bool complete;
        mapping(address => uint256) contributions;
        address[] contributors;
    }

    Project[] public projects;

    function createProject(
        string memory _title,
        string memory _description,
        uint256 _goalAmount,
        uint256 _duration
    ) public {
        uint256 deadline = block.timestamp + _duration;

        Project memory newProject = Project(
            payable(msg.sender),
            _title,
            _description,
            _goalAmount,
            0,
            deadline,
            false,
            new address[](0)
        );

        projects.push(newProject);
    }

    function contribute(uint256 _projectId) public payable {
        Project storage project = projects[_projectId];
        require(!project.complete, "Project is already completed");
        require(block.timestamp <= project.deadline, "Project deadline exceeded");
        require(msg.value > 0, "Contribution amount must be greater than 0");

        project.contributions[msg.sender] += msg.value;
        project.currentAmount += msg.value;

        if (!isContributor(_projectId, msg.sender)) {
            project.contributors.push(msg.sender);
        }
    }

    function completeProject(uint256 _projectId) public {
        Project storage project = projects[_projectId];
        require(!project.complete, "Project is already completed");
        require(block.timestamp > project.deadline, "Project deadline not yet exceeded");
        require(project.currentAmount >= project.goalAmount, "Project did not reach its funding goal");

        project.complete = true;
        project.creator.transfer(project.currentAmount);
    }

    function getProjectCount() public view returns (uint256) {
        return projects.length;
    }

    function getProjectDetails(uint256 _projectId)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        Project storage project = projects[_projectId];
        return (
            project.creator,
            project.title,
            project.description,
            project.goalAmount,
            project.currentAmount,
            project.deadline,
            project.complete
        );
    }

    function getContributorCount(uint256 _projectId) public view returns (uint256) {
        Project storage project = projects[_projectId];
        return project.contributors.length;
    }

    function getContributionAmount(uint256 _projectId, address _contributor)
        public
        view
        returns (uint256)
    {
        Project storage project = projects[_projectId];
        return project.contributions[_contributor];
    }

    function isContributor(uint256 _projectId, address _contributor) internal view returns (bool) {
        Project storage project = projects[_projectId];
        return project.contributions[_contributor] > 0;
    }
}
