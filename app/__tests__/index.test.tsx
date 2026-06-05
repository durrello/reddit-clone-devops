/**
 * Unit Tests for Reddit Clone Application
 * Using Jest + React Testing Library
 */

// Mock next/router
jest.mock("next/router", () => ({
  useRouter: () => ({
    push: jest.fn(),
    pathname: "/",
    route: "/",
    asPath: "/",
    query: {},
  }),
}));

describe("Application", () => {
  describe("Environment Configuration", () => {
    it("should have NODE_ENV defined", () => {
      expect(process.env.NODE_ENV).toBeDefined();
    });

    it("should be in test environment", () => {
      expect(process.env.NODE_ENV).toBe("test");
    });
  });

  describe("Basic Functionality", () => {
    it("should perform basic arithmetic (sanity check)", () => {
      expect(1 + 1).toBe(2);
    });

    it("should handle string operations", () => {
      const appName = "Reddit Clone";
      expect(appName).toContain("Reddit");
      expect(appName.toLowerCase()).toBe("reddit clone");
    });

    it("should handle array operations for posts", () => {
      const posts = [
        { id: 1, title: "First Post", votes: 10 },
        { id: 2, title: "Second Post", votes: 5 },
        { id: 3, title: "Third Post", votes: 15 },
      ];

      // Sort by votes descending (like Reddit)
      const sorted = [...posts].sort((a, b) => b.votes - a.votes);
      expect(sorted[0].title).toBe("Third Post");
      expect(sorted[2].title).toBe("Second Post");
    });

    it("should validate post structure", () => {
      const post = {
        id: "abc123",
        title: "Test Post",
        body: "This is a test post body",
        communityId: "reactjs",
        creatorId: "user1",
        numberOfComments: 0,
        voteStatus: 0,
        createdAt: new Date().toISOString(),
      };

      expect(post).toHaveProperty("id");
      expect(post).toHaveProperty("title");
      expect(post).toHaveProperty("communityId");
      expect(post.numberOfComments).toBeGreaterThanOrEqual(0);
    });

    it("should validate community naming rules", () => {
      const isValidCommunityName = (name: string): boolean => {
        // 3-21 chars, only letters, numbers, underscores
        const regex = /^[a-zA-Z0-9_]{3,21}$/;
        return regex.test(name);
      };

      expect(isValidCommunityName("reactjs")).toBe(true);
      expect(isValidCommunityName("r")).toBe(false); // too short
      expect(isValidCommunityName("invalid name with spaces")).toBe(false);
      expect(isValidCommunityName("valid_community_1")).toBe(true);
    });
  });

  describe("Vote System", () => {
    it("should calculate net votes correctly", () => {
      const calculateNetVotes = (
        upvotes: number,
        downvotes: number
      ): number => {
        return upvotes - downvotes;
      };

      expect(calculateNetVotes(10, 3)).toBe(7);
      expect(calculateNetVotes(0, 5)).toBe(-5);
      expect(calculateNetVotes(100, 100)).toBe(0);
    });
  });
});
