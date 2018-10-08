class Parent {
  public:
    Parent();
    virtual ~Parent();
    static void create();
  protected:
    static int m_intVar[N];
  private:
    struct Nested {
      Nested();
      ~Nested();
      double
        m_multiLineArray[L];
    };
};
